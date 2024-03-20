data "azurerm_subscription" "current" {
}


#
# Hub Deploy Roles
#

locals {
  hub_subscription_id = data.azurerm_subscription.current.id # assume we are running in the hub subscription
}
# note: this role will be assigned using the access role above
resource "azurerm_role_definition" "buildingblock_deploy_hub" {
  name        = "buildingblock-${var.name}-deploy-hub"
  description = "Enables deployment of the ${var.name} building block to the hub"
  scope       = local.hub_subscription_id

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/*",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*",
      "Microsoft.Network/virtualNetworks/peer/action"
    ]
  }
}

resource "azurerm_role_assignment" "buildingblock_deploy_hub" {
  for_each = var.principal_ids

  role_definition_id = azurerm_role_definition.buildingblock_deploy_hub.role_definition_resource_id
  description        = azurerm_role_definition.buildingblock_deploy_hub.description
  principal_id       = each.key
  scope       = local.hub_subscription_id
}


#
# Spoke Deploy Roles
# 

resource "azurerm_role_definition" "buildingblock_access_spoke" {
  name              = "buildingblock-${var.name}-access"
  description       = "Allow self-assignment of a deployment role on an application team's subscription that in turn enables provisioning of building block resources."
  scope             = var.scope
  assignable_scopes = [var.scope]

  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/*"
    ]
  }
}

# Ensure that the principals can only make assignments that assign itself the deploy role
resource "azurerm_role_assignment" "buildingblock_access_spoke" {
  for_each = var.principal_ids

  role_definition_id = azurerm_role_definition.buildingblock_access_spoke.role_definition_resource_id
  description        = azurerm_role_definition.buildingblock_access_spoke.description
  principal_id       = each.key
  scope              = var.scope

  condition_version = "2.0"

  # what this does: if the request is a roleAssignment write or a delete, check that it only contains the expected deploy role
  # this ensures that the principals can only escalate privileges to the known roles
  condition = <<-EOT
(
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
  AND
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
)
OR
(
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${azurerm_role_definition.buildingblock_deploy_spoke.role_definition_id}}
  AND
  @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {${each.key}}
)
EOT
}

# We have successfully restricted that the
# Use a policy to ensure that if we see an assignment of the deploy role to the principals, that it scope is
# a "connectivity" resource group. 
# Note: this is necessary because Azure ABAC does not support @Request[Microsoft.Authorization/roleAssignments:Scope] right now
resource "azurerm_policy_definition" "buildingblock_access" {
  name         = "${var.service_principal_name}_rbac"
  display_name = "Restrict ${var.service_principal_name} role assignments"
  description  = "Restrict building block automations to manage role assignments only on exclusively owned resource groups"
  policy_type  = "Custom"
  mode         = "All"

  management_group_id = var.scope

  parameters = <<EOF
  {
    "managedResourceGroups": {
      "type": "Array",
      "metadata": {
          "displayName": "Managed Resource Group Names",
          "description": "Name of the resource groups exclusively managed by this automation"
      }
    },
    "principalId": {
      "type": "String",
      "metadata": {
          "displayName": "Principal Id",
          "description": "Id of the automation principal allowed to access the managedResourceGroups"
      }
    },
    "roleDefinitionId": {
      "type": "String",
      "metadata": {
          "displayName": "Role Definition Id",
          "description": "Id of the role that can only be assigned on the managedResourceGroups"
      }
    }

  }
  EOF

  policy_rule = <<EOF
  {
    "if": {
      "allOf": [
        {
          "equals": "Microsoft.Authorization/roleAssignments",
          "field": "type"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/principalId",
          "equals": "[parameters('principalId')]"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/roleDefinitionId",
          "equals": "[parameters('roleDefinitionId')]"
        },
        {
          "value": "[resourceGroup().name]",
          "notIn": "[parameters('managedResourceGroups')]"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  EOF
}

resource "azurerm_management_group_policy_assignment" "buildingblock_access" {
  name                 = "restrict-bb-rbac" # we can only have 24 characters in the name...
  display_name         = azurerm_policy_definition.buildingblock_access.display_name
  description          = azurerm_policy_definition.buildingblock_access.description
  policy_definition_id = azurerm_policy_definition.buildingblock_access.id
  management_group_id  = var.scope

  parameters = jsonencode({
    principalId           = { value = azuread_service_principal.buildingblock.id }
    managedResourceGroups = { value = local.managedResourceGroups }
  })
}

# note: this role will be assigned using the access role above
resource "azurerm_role_definition" "buildingblock_deploy_spoke" {
  name        = "buildingblock-${var.name}-deploy-spoke"
  description = "Enables deployment of the ${var.name} building block spoke to subscriptions."
  scope       = data.azurerm_subscription.current.id # assume we are running in the spoke subscription anyway

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/*",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*"
    ]
  }
}


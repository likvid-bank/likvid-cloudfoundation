data "azurerm_subscription" "current" {
}

# set up roles that we will need at the top of the management group hierarchy

#
# Access Role
#
resource "azurerm_role_definition" "buildingblock_access" {
  name              = "buildingblock-${var.name}-access"
  description       = "Allow self-assignment of a deployment role on an application team's subscription that in turn enables provisioning of building block resources."
  scope             = var.scope
  assignable_scopes = [var.scope]

  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Resources/subscriptions/resourceGroups/*"
    ]
  }
}

locals {
  connectivity_rg_name = "connectivity"
}

resource "azurerm_policy_definition" "buildingblock_access" {
  name = "buildingblock-${var.name}-access"
  display_name = "buildingblock-${var.name}-access"
  description = "Restricts access of operations to the connectivity resource group"
  policy_type = "Custom"
  mode = "All"

  management_group_id = var.scope

    # "allowedResourceGroup": {
    #     "type": "String",
    #     "metadata": {
    #         "displayName": "Allowed Resource Group Name",
    #         "description": "Name of the allowed resource group"
    #     }
    # },
  parameters = <<EOF
  {

    "allowedPrincipalIds": {
        "type": "Array",
        "metadata": {
            "displayName": "Allowed PrinfipalIds",
            "description": "The allowed resource group naming convention. Use # for a number, ? for a letter, or . for any character. Or specify specific characters to use."
        }
    }
  }
  EOF

  # TODO: use connectivity name as parameter
  # TODO: right now does not prevent the automation SPN from adding/removing any other RGs
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
          "in": "[parameters('allowedPrincipalIds')]"
        },        
        {
          "field": "Microsoft.Authorization/roleAssignments/scope",
          "notLike": "*/resourceGroups/connectivity"
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
  name = "bb-${var.name}" # we can only have 24 characters in the name...
  display_name = azurerm_policy_definition.buildingblock_access.name
  management_group_id = var.scope
  policy_definition_id = azurerm_policy_definition.buildingblock_access.id
  
  parameters = jsonencode({
    allowedPrincipalIds: {value = var.principal_ids}
    #allowedResourceGroup: {value = local.connectivity_rg_name}
  })
}

#
# Deploy Roles
#

# note: this role will be assigned using the access role above
resource "azurerm_role_definition" "buildingblock_deploy_hub" {
  name        = "buildingblock-${var.name}-deploy-hub"
  description = "Enables deployment of the ${var.name} building block to the hub"
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


resource "azurerm_role_assignment" "buildingblock_deploy_hub" {
  for_each = var.principal_ids

  role_definition_id = azurerm_role_definition.buildingblock_deploy_hub.role_definition_resource_id
  description        = azurerm_role_definition.buildingblock_deploy_hub.description
  principal_id       = each.key
  scope              = data.azurerm_subscription.current.id # assume we are running in the spoke subscription anyway
}
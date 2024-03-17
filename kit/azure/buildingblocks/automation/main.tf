data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "tfstates_engineers" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.buildingblock.id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

# the BB Automation SPN needs some default permissions in order to be able to deploy building blocks that require
# "controlled privilege escalation"
resource "azurerm_role_definition" "buildingblock_plan" {
  name        = "${var.service_principal_name}-plan"
  description = "Enables read only access in order to plan building block deployments"
  scope       = var.scope

  permissions {
    actions = [
      # Reading management groups
      "Microsoft.Management/managementGroups/read",
      "Microsoft.Management/managementGroups/descendants/read",
      "Microsoft.Management/managementgroups/subscriptions/read",
      "Microsoft.Resources/tags/read",
      
      # Note: these will be restricted by policy
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/write", # note: access to deleting an RG is granted by making the SPN an owner on the RG
      
      # Permission we need to activate/register required Resource Providers
      "Microsoft.Resources/subscriptions/providers/read",
      "*/register/action",
    ]
  }
}

resource "azurerm_role_assignment" "buildingblock_deploy" {
  role_definition_id = azurerm_role_definition.buildingblock_plan.role_definition_resource_id
  principal_id       = azuread_service_principal.buildingblock.id
  scope              = var.scope
}


resource "azurerm_policy_definition" "buildingblock_access" {
  name = "${var.service_principal_name}-deploy"
  display_name = "${var.service_principal_name}-deploy"
  description = "Restricts access of automation operations to specific resource groups"
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
  # TODO: right now does not prevent the automation SPN from adding any other RGs. The good news is that the SPN has no delete RG rights via the subscription.
  # TODO: right now this policy will prevent assigning any other role to this principal, it may thus be better kept at the buildingblocks/automation level
  # this is a limitation of Azure not offering sufficiently powerful conditions, e.g. resource based Policys can't detect this
  # and Azure ABAC does not contain sufficiently powerful expressions
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
          "not": {
            "anyOf": [
              {
                "value": "[resourceGroup().name]",
                "equals": "connectivity"
              }
            ]
          }
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
  name = "restrict-bb-automation" # we can only have 24 characters in the name...
  display_name = "Restrict building block automations to exclusively owned resource groups"
  management_group_id = var.scope
  policy_definition_id = azurerm_policy_definition.buildingblock_access.id
  
  parameters = jsonencode({
    allowedPrincipalIds: {value = [azuread_service_principal.buildingblock.id]}
    #allowedResourceGroup: {value = local.connectivity_rg_name}
  })
}

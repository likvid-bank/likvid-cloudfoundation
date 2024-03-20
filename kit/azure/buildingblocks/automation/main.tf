data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "tfstates_engineers" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.buildingblock.id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

# DESIGN: the BB Automation SPN needs some default permissions in order to be able to deploy building blocks that
# require access to deploy resources in target subscriptions.
#
# We therefore grant two very powerful permissions: manage all RoleAssignments and manage all ResourceGroups.
# However, we take great care to limit those permissions via policy so that the principal can only use them on
# specifically whitelisted resource groups.

locals {
  managedResourceGroups = ["connectivity"]
}

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
      "Microsoft.Resources/subscriptions/resourceGroups/read",

      # Note: these will be restricted by policy
      "Microsoft.Authorization/roleAssignments/*",

      
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


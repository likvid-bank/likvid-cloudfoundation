data "azurerm_subscription" "current" {
}

// TODO: document design decisions for platform engineers _> move code comment to readme

# give the SPN permission to acess the terraform state
resource "azurerm_role_assignment" "terraform_state" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.buildingblock.object_id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

# DESIGN: this is a very simple building block, which means we let the SPN have access to deploy budget alerts 
# across all subscriptions.
resource "azurerm_role_definition" "buildingblock_deploy" {
  name        = "${azuread_service_principal.buildingblock.display_name}-deploy"
  description = "Enables deployment of the ${var.name} building block to subscriptions"
  scope       = var.scope

  permissions {
    actions = [
        "Microsoft.Consumption/budgets/*",
    ]
  }
}

resource "azurerm_role_assignment" "buildingblock_deploy" {
  role_definition_id   = azurerm_role_definition.buildingblock_deploy.role_definition_resource_id
  principal_id         = azuread_service_principal.buildingblock.object_id
  scope                = var.scope
}

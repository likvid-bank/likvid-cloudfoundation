# configure our logging subscription
data "azurerm_subscription" "current" {
}

resource "azurerm_role_assignment" "terraform_state" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.starterkit.object_id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

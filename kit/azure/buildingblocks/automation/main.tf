data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "tfstates_engineers" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.buildingblock.id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}
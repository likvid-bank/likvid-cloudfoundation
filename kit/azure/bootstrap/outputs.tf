output "tfstates_resource_group_name" {
    value = azurerm_resource_group.tfstates.name
}
 output "tfstates_storage_account_name" {
   value = azurerm_storage_account.tfstates.name
 }

 output "tfstates_container_name" {
   value = azurerm_storage_container.tfstates.name
 }

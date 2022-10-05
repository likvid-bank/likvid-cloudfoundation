
output "platform_management_group_id" {
  value = azurerm_management_group.platform.id
}

output "prod_management_group_id" {
  description = "id of the Prod management group"
  value       = azurerm_management_group.prod.id
}

output "dev_management_group_id" {
  description = "id of the dev management group"
  value       = azurerm_management_group.dev.id
}

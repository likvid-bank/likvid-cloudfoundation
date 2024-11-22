output "management_id" {
  value = azurerm_management_group.container_platform.id
}

output "dev_management_id" {
  value = azurerm_management_group.dev.id
}

output "prod_management_id" {
  value = azurerm_management_group.prod.id
}


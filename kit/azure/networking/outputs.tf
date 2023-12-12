output "hub-location" {
  value = var.location
  description = "Location of hub vnet" 
}

output "hub-rg" {
  value = azurerm_resource_group.this.name
  description = "Resource Group of hub vnet"
}

output "hub-vnet" {
  value = azurerm_virtual_network.this.name
  description = "Name of hub vnet"
}

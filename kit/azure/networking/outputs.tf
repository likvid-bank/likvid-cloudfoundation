output "hub_subscription" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Subscription of hub vnet"
}

output "hub_location" {
  value       = var.location
  description = "Location of hub vnet"
}

output "hub_rg" {
  value       = azurerm_resource_group.this.name
  description = "Resource Group of hub vnet"
}

output "hub_vnet" {
  value       = azurerm_virtual_network.this.name
  description = "Name of hub vnet"
}

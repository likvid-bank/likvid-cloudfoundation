data "azurerm_subscription" "current" {
  
}

output "name" {
  value = data.azurerm_subscription.current
} 

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstates" {
  name     = "cloudfoundation-tfstates"
  location = var.location
}

resource "azurerm_storage_account" "tfstates" {
  name                     = "tfstates${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstates.name
  location                 = azurerm_resource_group.tfstates.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstates" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.tfstates.name
  container_access_type = "blob"
}
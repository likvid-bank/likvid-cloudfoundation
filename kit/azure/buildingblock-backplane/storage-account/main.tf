# Place your module's terraform resources here as usual.
# Note that you should typically not put a terraform{} block into cloud foundation kit modules,
# these will be provided by the platform implementations using this kit module.
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Resource-1 Resource Group
resource "azurerm_resource_group" "rg_storage_account" {
  name     = var.resource_group_name
  location = var.location
}

# Resource-2 Storage account
resource "azurerm_storage_account" "storage" {
  name                      = var.storage_account_name
  resource_group_name       = azurerm_resource_group.rg_storage_account.name
  location                  = azurerm_resource_group.rg_storage_account.location
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  access_tier               = var.access_tier
  enable_https_traffic_only = true
  min_tls_version           = var.min_tls_version

  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention
    }
  }
}



# Resource-3 Storage account's container
resource "azurerm_storage_container" "container" {
  count                 = length(var.containers)
  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.containers[count.index].access_type
}


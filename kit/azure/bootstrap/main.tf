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
  account_replication_type = "GRS"
  shared_access_key_enabled = false
}

resource "azurerm_storage_container" "tfstates" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.tfstates.name
  container_access_type = "blob"
}

# Set permissions on the blob store


data "azuread_users" "platform_engineers_members" {
  # unfortunately mail_nicknames attribute does not work on our AADs because we don't sync from on-premise
  # so we have to use user prinicpal names for lookups
  user_principal_names = var.platform_engineers_members[*].upn
}

data "azuread_client_config" "current" {}

resource "azuread_group" "platform_engineers" {
  display_name     = "cloudfoundation-platform-engineers"
  owners           = [data.azuread_client_config.current.object_id] # todo: possibly the owner needs to be the cloudfoundation SPN? need to figure out dependency order inside the boostrap module!
  security_enabled = true

  members = toset(data.azuread_users.platform_engineers_members.object_ids)
}

resource "azurerm_role_assignment" "tfstates_engineers" {
  principal_id = azuread_group.platform_engineers.object_id

  role_definition_name = "Storage Blob Data Owner"
  scope = azurerm_storage_container.tfstates.resource_manager_id
}

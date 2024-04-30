data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "key_vault" {
  name     = var.key_vault.resource_group_name
  location = var.terraform_state_storage.location
}

resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault.name
  location                   = var.terraform_state_storage.location
  resource_group_name        = azurerm_resource_group.key_vault.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = true
}

data "azurerm_role_definition" "keyvault" {
  name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "cloudfoundation_tfdeploy" {
  principal_id         = azuread_group.platform_engineers.id
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = data.azurerm_role_definition.keyvault.name
}

resource "azurerm_key_vault_key" "generated" {
  name         = "generated-certificate"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

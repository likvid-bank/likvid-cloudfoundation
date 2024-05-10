data "azurerm_key_vault" "cloudfoundation_keyvault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

data "azurerm_key_vault_secret" "github_token" {
  name         = var.github_token_secret_name
  key_vault_id = data.azurerm_key_vault.cloudfoundation_keyvault.id
}


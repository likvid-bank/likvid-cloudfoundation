data "azurerm_key_vault" "cloudfoundation_keyvault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

data "azurerm_key_vault_secret" "github_token" {
  name         = var.github_token_secret_name
  key_vault_id = data.azurerm_key_vault.cloudfoundation_keyvault.id
}

provider "github" {
  token = data.azurerm_key_vault_secret.github_token.value
  owner = var.github_owner 
}

resource "github_repository" "repository" {
  count                = var.create_new ? 1 : 0
  name                 = var.repo_name
  description          = var.description
  visibility           = var.visibility
  auto_init            = false
  vulnerability_alerts = true

  dynamic "template" {
    for_each = var.use_template ? [1] : []
    content {
      owner                = var.template_owner
      repository           = var.template_repo
      include_all_branches = true
    }
  }
}

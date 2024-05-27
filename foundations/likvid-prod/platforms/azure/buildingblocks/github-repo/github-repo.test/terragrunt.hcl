dependency "bootstrap" {
  config_path = "../../../bootstrap"
}

dependency "automation" {
  config_path = "../../automation"
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/github-repo/buildingblock"
}

# generate a config.tf file for automating building block deployments via meshStack
generate "config" {
  path      = "config.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${dependency.automation.outputs.tenant_id}"
    subscription_id       = "${dependency.automation.outputs.subscription_id}"
    resource_group_name   = "${dependency.automation.outputs.resource_group_name}"
    storage_account_name  = "${dependency.automation.outputs.storage_account_name}"
    container_name        = "${dependency.automation.outputs.container_name}"
    key                   = "github-repo.tfstate"

    client_id             = "${dependency.automation.outputs.client_id}"
    client_secret         = "${dependency.automation.outputs.client_secret}"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${dependency.automation.outputs.tenant_id}"
  subscription_id = "${dependency.automation.outputs.subscription_id}"
  storage_use_azuread = true

  client_id             = "${dependency.automation.outputs.client_id}"
  client_secret         = "${dependency.automation.outputs.client_secret}"
}
EOF
}

inputs = {

  key_vault_name             = dependency.bootstrap.outputs.azurerm_key_vault.name
  key_vault_rg               = dependency.bootstrap.outputs.azurerm_key_vault_rg_name
  github_app_id              = "654209"
  github_app_installation_id = "44437049"
  github_org                 = "likvid-bank"
  github_token_secret_name   = "likvid-bank-devops-toolchain-team"
  repo_name                  = "likvid-github-repo-test"
  create_new                 = true
  visibility                 = "private"
  use_template               = false
  template_owner             = "fnowarre@meshcloud.io"
}

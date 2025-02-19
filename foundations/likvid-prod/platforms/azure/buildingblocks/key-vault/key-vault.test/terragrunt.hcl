# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../backplane"
}

dependency "automation" {
  config_path = "../../automation"
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
    key                   = "key-vault.tfstate"

    client_id             = "${dependency.automation.outputs.client_id}"
    client_secret         = "${dependency.automation.outputs.client_secret}"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = false
  storage_use_azuread        = true

  tenant_id       = "${dependency.automation.outputs.tenant_id}"

  # this var will be injected by the buildingblock runner
  subscription_id = var.subscription_id

  client_id             = "${dependency.automation.outputs.client_id}"
  client_secret         = "${dependency.automation.outputs.client_secret}"
}

provider "azuread" {
  tenant_id       = "${dependency.automation.outputs.tenant_id}"

  client_id       = "${dependency.automation.outputs.client_id}"
  client_secret   = "${dependency.automation.outputs.client_secret}"
}


EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/key-vault/buildingblock"
}

inputs = {
  subscription_id = "c4a1f7bc-9a89-4a8d-a03f-3df5c639bd5d"
}

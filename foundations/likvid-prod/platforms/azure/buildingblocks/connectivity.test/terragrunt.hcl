# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../connectivity"
}

dependency "automation" {
  config_path = "../automation"
}

dependency "networking" {
  config_path = "../../networking"
}

# generate a config.tf file for automating building block deployments via meshStack
# note: "terraform test" will ignore the terraform and provider blocks
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
    key                   = "connectivity.tfstate"

    client_id             = "${dependency.automation.outputs.client_id}"
    client_secret         = "${dependency.automation.outputs.client_secret}"
  }
}

provider "azurerm" {
  features {}

  alias = "hub"

  skip_provider_registration = false
  storage_use_azuread        = true

  tenant_id       = "${dependency.automation.outputs.tenant_id}"
  subscription_id = "${dependency.networking.outputs.hub_subscription}"

  client_id             = "${dependency.automation.outputs.client_id}"
  client_secret         = "${dependency.automation.outputs.client_secret}"
}

provider "azurerm" {
  features {}

  alias = "spoke"

  skip_provider_registration = false
  storage_use_azuread        = true

  tenant_id       = "${dependency.automation.outputs.tenant_id}"

  # this var will be injected by the buildingblock runner
  subscription_id = var.subscription_id

  client_id             = "${dependency.automation.outputs.client_id}"
  client_secret         = "${dependency.automation.outputs.client_secret}"
}

# This building block additionally needs a few locals directly injected into the terraform module.
# This way we avoid needing to provide them as inputs via meshStack for a quicker integration experience.
# however, they should arguably be static inputs

locals {
  principal_id = "${dependency.automation.outputs.principal_id}"
  access_role_definition_id = "${dependency.buildingblock.outputs.access_role_definition_id}"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/connectivity/buildingblock"
}

inputs = {
  subscription_id = "c4a1f7bc-9a89-4a8d-a03f-3df5c639bd5d"

  # tbd: all of these are more or less "static" for the backplane
  hub_rg   = dependency.networking.outputs.hub_rg
  hub_vnet = dependency.networking.outputs.hub_vnet
  location = dependency.networking.outputs.hub_location
}
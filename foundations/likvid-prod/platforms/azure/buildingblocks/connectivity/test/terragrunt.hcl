# this module only supports the test command!
exclude {
  if      = true
  actions = ["plan", "apply", "destroy"]
}

# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../backplane"
}

dependency "automation" {
  config_path = "../../automation"
}

dependency "networking" {
  config_path = "../../../networking"
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
EOF
}


terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/connectivity/buildingblock?ref=v0.5.3"
  # the extra_arguments is a workarround for an bug in the Azure API after creating the spoke_vnet
  # network.VirtualNetworkPeeringsClient#CreateOrUpdate: Failure sending request: StatusCode=403
  # this pre run of an spoke_vnet apply will fix the issue in test scenarios
  extra_arguments "custom_vars" {
    commands = ["apply"]
    arguments = [
      "--target=azurerm_virtual_network.spoke_vnet"
    ]
  }
}

inputs = {
  subscription_id = "c4a1f7bc-9a89-4a8d-a03f-3df5c639bd5d"

  # tbd: all of these are more or less "static" for the backplane
  hub_rg   = dependency.networking.outputs.hub_rg
  hub_vnet = dependency.networking.outputs.hub_vnet
  location = dependency.networking.outputs.hub_location
}

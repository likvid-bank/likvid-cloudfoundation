include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "networking" {
  config_path = "../../../networking"
}

dependency "automation" {
  config_path = "../../automation"
}

# deploy to the hub subscription
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${dependency.networking.outputs.hub_subscription}"
  storage_use_azuread = true
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/connectivity/backplane?ref=v0.5.3"
}

inputs = {
  name = "connectivity"

  principal_ids = toset([
    dependency.networking.outputs.network_admins_azuread_group_id,
    dependency.automation.outputs.principal_id
  ])
}

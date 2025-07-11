include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/landingzones/corp-online"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "../../organization-hierarchy"
}

dependency "networking" {
  config_path = "../../networking"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}
EOF
}

inputs = {
  # todo: set input variables
  vnet_address_space_id      = "${dependency.networking.outputs.hub_vnet_id}"
  cloudfoundation            = "${include.platform.locals.cloudfoundation.name}"
  parent_management_group_id = "${dependency.organization-hierarchy.outputs.landingzones_id}"
  location                   = "germanywestcentral"
}

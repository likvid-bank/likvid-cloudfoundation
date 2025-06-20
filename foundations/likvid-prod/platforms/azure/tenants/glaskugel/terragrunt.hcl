include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

// this is not a standard platform module that uses a kit module, instead we call this a "tenant module"
// that contains its own terraform code and just pulls in plain terraform modules (building blocks) for reusable modules
terraform {
  source = "./"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

dependency "networking" {
  config_path = "../../networking"
}

dependency "corp_online" {
  config_path = "../../landingzones/corp-online"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "670095a3-3c3b-42a8-a190-b8503113fa05"
}

provider "azurerm" {
  features {}
  alias           = "hub"
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${dependency.networking.outputs.hub_subscription}"
}
EOF
}

inputs = {
  corp_management_group    = dependency.corp_online.outputs.corp_id
  hub_rg                   = dependency.networking.outputs.hub_rg
  hub_vnet                 = dependency.networking.outputs.hub_vnet
  spoke_owner_principal_id = dependency.networking.outputs.network_admins_azuread_group_id
}
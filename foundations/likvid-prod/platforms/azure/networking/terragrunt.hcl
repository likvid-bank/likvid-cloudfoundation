include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/networking"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "../organization-hierarchy"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"

  subscription_id = "5066eff7-4173-4fea-8c67-268456b4a4f7"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"
}
EOF
}

inputs = {
  scope                               = "${dependency.organization-hierarchy.outputs.landingzones_id}"
  cloudfoundation_deploy_principal_id = "${dependency.bootstrap.outputs.client_principal_id}"
  parent_management_group_id          = "${dependency.organization-hierarchy.outputs.connectivity_id}"
  address_space                       = ["10.0.0.0/16"]
  location                            = "germanywestcentral"
}

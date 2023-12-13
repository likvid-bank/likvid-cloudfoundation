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

  # recommended: use a separate subscription for networking
  subscription_id = "the-id-of-your-networking-subscription"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"
}
EOF
}

inputs = {
  # todo: set input variables
  cloudfoundation_deploy_principal_id = "${dependency.bootstrap.outputs.client_principal_id}"
  parent_management_group_id = "${dependency.organization-hierarchy.outputs.connectivity_id}"
  address_space       = [ "10.0.0.0/16" ]
  location            = "germanywestcentral"
}

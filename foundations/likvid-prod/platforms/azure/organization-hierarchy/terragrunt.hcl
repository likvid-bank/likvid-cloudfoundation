include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "${path_relative_from_include()}/bootstrap"
}

terraform {
  source = "${get_repo_root()}//kit/azure/organization-hierarchy"
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
  locations = ["germanywestcentral", "westeurope"]

  connectivity          = "likvid-connectivity"
  identity              = "likvid-identity"
  landingzones          = "likvid-landingzones"
  management            = "likvid-management"
  parentManagementGroup = "likvid-foundation"
  platform              = "likvid-platform"

}

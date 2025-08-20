include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "corp_online" {
  config_path = "../corp-online"
}

terraform {
  source = "${get_repo_root()}//kit/azure/landingzones/au-cloud-native"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
  }
EOF
}

inputs = {
  name                       = "au-cloudnative"
  parent_management_group_id = dependency.corp_online.outputs.online_id
}

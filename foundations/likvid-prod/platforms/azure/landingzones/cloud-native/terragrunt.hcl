include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "${path_relative_from_include()}/bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "${path_relative_from_include()}/organization-hierarchy"
}

terraform {
  source = "${get_repo_root()}//kit/azure/landingzones/cloud-native"
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
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"
  }
EOF
}

# these management groups existed before likvid bank's cloud foundation team managed its landing zones via terraform
# so we import them here by simply letting terragrunt inject a few import blocks into the terraform configuration
generate "import" {
  path      = "import.tf"
  if_exists = "overwrite"
  contents  = <<EOF
import {
  to = azurerm_management_group.dev
  id = "/providers/Microsoft.Management/managementGroups/likvid-dev"
}

import {
  to = azurerm_management_group.prod
  id = "/providers/Microsoft.Management/managementGroups/stage-prod"
}
EOF
}

inputs = {
  name                       = "cloudnative"
  parent_management_group_id = dependency.organization-hierarchy.outputs.online_id
}
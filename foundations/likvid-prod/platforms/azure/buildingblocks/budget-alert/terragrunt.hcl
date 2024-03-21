include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# we deploy to the management subscription here, as budget alerts are central to all LZs
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
  storage_use_azuread = true
  }
EOF
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "../../organization-hierarchy"
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/budget-alert"
}

inputs = {
  name                   = "budget-alert"
  service_principal_name = "buildingblock-budget-alert"
  scope                  = dependency.organization-hierarchy.outputs.landingzones_id
  location               = "germanywestcentral"
  bb_admins_group_id     = dependency.bootstrap.outputs.platform_engineers_azuread_group_id,
}
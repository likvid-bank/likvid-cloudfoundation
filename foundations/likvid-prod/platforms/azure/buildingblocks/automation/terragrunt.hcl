include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization-hierarchy" {
  config_path = "../../organization-hierarchy"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread        = true

  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/automation"
}

inputs = {
  location               = "germanywestcentral"
  service_principal_name = "likvid_foundation_tf_buildingblock_user"
  scope                  = dependency.organization-hierarchy.outputs.landingzones_id

}



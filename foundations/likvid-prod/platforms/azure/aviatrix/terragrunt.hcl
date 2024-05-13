include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/aviatrix"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "automation" {
  config_path = "../buildingblocks/automation"
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
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
}
EOF
}

inputs = {
  # todo: set input variables
  service_principal_name  = "likvid_avaitrix_deploy_spn"
  parent_management_group = dependency.organization-hierarchy.outputs.landingzones_id
  allowed_user_group_id   = ["${dependency.bootstrap.outputs.platform_engineers_azuread_group_id}", "${dependency.automation.outputs.principal_id}"]
  location                = "${try(include.platform.locals.tfstateconfig.location, "could not read location from stateconfig. configure it explicitly")}"
  # todo: azure will throw an error if date is in a past month

}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/logging"
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

  subscription_id = "e4a6af88-cd23-4785-acd6-d7221f755be7"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
}

provider "azapi" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "e4a6af88-cd23-4785-acd6-d7221f755be7"
}
EOF
}

inputs = {
  scope = dependency.organization-hierarchy.outputs.parent_id

  cloudfoundation_deploy_principal_id = dependency.bootstrap.outputs.platform_engineers_azuread_group_id
  cloudfoundation                     = include.platform.locals.cloudfoundation.name

  location              = "germanywestcentral"
  log_retention_in_days = 180

  parent_management_group_id = dependency.organization-hierarchy.outputs.management_id
  security_admin_group       = "likvid-cloudfoundation-security-admins"
  security_auditor_group     = "likvid-cloudfoundation-security-auditors"
}

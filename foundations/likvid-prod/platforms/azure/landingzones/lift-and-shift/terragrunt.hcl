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

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "e1c85eff-0a2c-4268-9b6c-7d2ff9ca9848" # likvid-lift-and-shift (subscription already exists)
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/landingzones/lift-and-shift"
}

inputs = {
  lift_and_shift_subscription_name = "likvid-lift-and-shift"
  parent_management_group_id       = dependency.organization-hierarchy.outputs.landingzones_id
}
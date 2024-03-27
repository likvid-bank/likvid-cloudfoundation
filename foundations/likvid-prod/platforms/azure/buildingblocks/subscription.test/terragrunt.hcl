# this is a test for a collie building block
# this is a building block that's not going to be automated via meshStack, so we can simplify a few things here
# see the budget-alert building block for a building block that's both deployable by collie as well as meshStack

# use the standard backend
include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "buildingblock" {
  config_path = "../subscription"
}

dependency "corp_online" {
  config_path = "../../landingzones/corp-online"
}

# configure a provider to use our "buildingblock test" subscription
generate "config" {
  path      = "config.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}

  skip_provider_registration = false
  storage_use_azuread        = true

  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "c4a1f7bc-9a89-4a8d-a03f-3df5c639bd5d"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblocks/subscription/buildingblock"
}

inputs = {
  subscription_name       = "likvid-prod-buildingblock-test"
  parent_management_group = dependency.corp_online.outputs.corp_id # note: the subscription needs to live in likvid-corp because we use it also for connectivity scenario tests
}
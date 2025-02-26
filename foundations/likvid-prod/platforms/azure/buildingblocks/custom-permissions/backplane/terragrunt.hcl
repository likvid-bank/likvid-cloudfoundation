include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# we deploy to the management subscription here, as custom permissions are central to all LZs
# we also deploy the backplane like all other platform modules with azure-cli auth
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

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/custom-permissions/backplane?ref=v0.5.3"
}

dependency "organization-hierarchy" {
  config_path = "../../../organization-hierarchy"
}

dependency "automation" {
  config_path = "../../automation"
}

inputs = {
  name          = "likvid-prod-custom-permissions"
  scope         = dependency.organization-hierarchy.outputs.landingzones_id
  principal_ids = toset([dependency.automation.outputs.principal_id])
}

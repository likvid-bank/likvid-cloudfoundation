include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# we deploy to the management subscription here, as budget alerts are central to all LZs
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

provider "azuread" {
  tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
}
EOF
}

dependency "bootstrap" {
  config_path = "../../../bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "../../../organization-hierarchy"
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/budget-alert/backplane?ref=e960738253a03d63619d27f593e293ccb963f776"
}

inputs = {
  name                          = "buildingblock-budget-alert-deploy"
  scope                         = dependency.organization-hierarchy.outputs.landingzones_id
  create_service_principal_name = "buildingblock-budget-alert-deploy"

  workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.likvid-cloud.buildingblockdefinition.8b806194-e3b1-41b3-aa56-7cb170234719"
  }
}

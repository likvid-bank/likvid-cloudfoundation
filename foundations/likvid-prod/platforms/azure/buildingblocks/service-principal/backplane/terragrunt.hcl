include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# we deploy to the management subscription here
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
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/service-principal/backplane?ref=cd2b6b3f47e071c1364fd544af32065fa9bb3516"
}

inputs = {
  name                          = "buildingblock-service-principal-deploy"
  scope                         = dependency.organization-hierarchy.outputs.landingzones_id
  create_service_principal_name = "buildingblock-service-principal-deploy"

  workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.m25-platform.buildingblockdefinition.58380b74-c5d7-4bbf-9d0f-ac10ed1def89"
  }
}

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
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/key-vault/backplane?ref=f5c30bdcee12cc36a434c92e0015e4d83092b60c"
}

inputs = {
  name                              = "buildingblock-key-vault-deploy"
  scope                             = dependency.organization-hierarchy.outputs.landingzones_id
  hub_scope                         = "/subscriptions/5066eff7-4173-4fea-8c67-268456b4a4f7"
  create_service_principal_name     = "buildingblock-key-vault-deploy"
  create_hub_service_principal_name = "buildingblock-key-vault-deploy-hub-connection"

  workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.m25-platform.buildingblockdefinition.e11b29dd-a05e-44bc-9ac5-365ebbf06004"
  }

  hub_workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.m25-platform.buildingblockdefinition.e11b29dd-a05e-44bc-9ac5-365ebbf06004"
  }
}

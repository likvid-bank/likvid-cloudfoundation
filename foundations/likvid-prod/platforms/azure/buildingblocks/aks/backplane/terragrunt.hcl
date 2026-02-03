include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
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
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/aks/backplane?ref=5868eeeb7c48fdbda139ec0127e0cb6547f73361"
}

inputs = {
  name                              = "buildingblock-aks-cluster-deploy"
  scope                             = dependency.organization-hierarchy.outputs.landingzones_id
  hub_scope                         = "/subscriptions/5066eff7-4173-4fea-8c67-268456b4a4f7"
  create_service_principal_name     = "buildingblock-aks-cluster-deploy"
  create_hub_service_principal_name = "buildingblock-aks-cluster-deploy-hub-connection"

  workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.kubecon-2025.buildingblockdefinition.b24da8d7-352d-458d-bc67-f3d72dda949e"
  }

  hub_workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:workspace.kubecon-2025.buildingblockdefinition.b24da8d7-352d-458d-bc67-f3d72dda949e"
  }
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

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
EOF
}

dependency "organization-hierarchy" {
  config_path = "../../../organization-hierarchy"
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/azure-virtual-machine/backplane?ref=6386b5a1a5d166fb9446370d1de2654e49370c65"
}

inputs = {
  name                          = "vm-deployer"
  scope                         = dependency.organization-hierarchy.outputs.landingzones_id
  create_service_principal_name = "vm-deployer"
  workload_identity_federation = {
    issuer  = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    subject = "system:serviceaccount:meshcloud-demo:tfrunner-66ddc814-1e69-4dad-b5f1-3a5bce51c01f"
  }
}

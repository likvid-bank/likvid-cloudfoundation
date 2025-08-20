include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "au-cloud-native" {
  config_path = "../landingzones/au-cloud-native"
}

terraform {
  source = "${get_repo_root()}//kit/azure/meshplatform-au"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}
EOF
}

inputs = {
  sso_enabled = false

  replicator_service_principal_name = "au-replicator.likvid.meshcloud.io"

  # nothing special for AU in metering, but we need to set this to avoid errors in the module
  # this should be fixed so that we can disable metering when not providing any metering related inputs
  metering_service_principal_name = "au-metering.likvid.meshcloud.io"

  replicator_custom_role_scope = dependency.au-cloud-native.outputs.au-cloudnative.name
  metering_assignment_scopes   = [dependency.au-cloud-native.outputs.au-cloudnative.name]
  replicator_assignment_scopes = [dependency.au-cloud-native.outputs.au-cloudnative.name]
  additional_permissions       = ["Microsoft.Subscription/rename/action"]

  can_cancel_subscriptions_in_scopes = [
    dependency.au-cloud-native.outputs.au-cloudnative.id
  ]

  create_passwords = false
  workload_identity_federation = {
    issuer             = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    replicator_subject = "system:serviceaccount:meshcloud-demo:replicator"
    kraken_subject     = "system:serviceaccount:meshcloud-demo:kraken-worker"
  }

  administrative_unit_name = "likvid"
}

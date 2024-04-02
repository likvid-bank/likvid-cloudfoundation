include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
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
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/meshplatform"
}

inputs = {
  sso_enabled           = false
  replicator_rg_enabled = true

  replicator_service_principal_name = "replicator.likvid.meshcloud.io"
  metering_service_principal_name   = "metering.likvid.meshcloud.io"

  replicator_custom_role_scope = include.platform.locals.platform.azure.aadTenantId
  metering_assignment_scopes   = ["${include.platform.locals.platform.azure.aadTenantId}"]
  replicator_assignment_scopes = ["${include.platform.locals.platform.azure.aadTenantId}"]
  additional_permissions       = ["Microsoft.Subscription/rename/action"]
}

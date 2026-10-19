include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "organization_hierarchy" {
  config_path = "../../organization-hierarchy"
}

# The hub root module creates both the backplane and the building block definition, so it needs a
# meshStack provider as well as azurerm. The backplane goes into the management subscription, since
# budget alerts are central to all landing zones, and is applied with azure-cli auth like every
# other platform module here.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  tenant_id           = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id     = "${include.platform.locals.platform.azure.subscriptionId}"
  storage_use_azuread = true
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${include.hub.locals.module}?ref=${include.hub.locals.git_ref}"
}

inputs = {
  hub = {
    git_ref   = include.hub.locals.git_ref
    bbd_draft = include.hub.locals.bbd_draft
  }

  meshstack = {
    owning_workspace_identifier = "devops-platform"
  }

  azure_tenant_id       = include.platform.locals.platform.azure.aadTenantId
  azure_subscription_id = include.platform.locals.platform.azure.subscriptionId
  azure_scope           = dependency.organization_hierarchy.outputs.landingzones_id
  azure_location        = "germanywestcentral"

  backplane_name = "likvid-azure-budget-alert"
}

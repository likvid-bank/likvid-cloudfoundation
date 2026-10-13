include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "networking" {
  config_path = "../../networking"
}

dependency "corp_online" {
  config_path = "../../landingzones/corp-online"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  tenant_id           = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id     = "${dependency.networking.outputs.hub_subscription}"
  storage_use_azuread = true
}
provider "meshstack" {
  endpoint = "https://federation.demo.meshcloud.io"
  # create your own API key with
  # - BBD read/write/delete permissions
  # - Integrations read permissions
  # in https://panel.demo.meshcloud.io/#/w/m25-platform/access-management/api-keys
  # and set MESHSTACK_API_KEY and MESHSTACK_API_SECRET env vars.
}

EOF
}

# meshcloud/meshstack-hub#385, which fixes the integration's undeclared azure_tenant_id. Move both
# refs to a main commit once it merges.
terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/spoke-network?ref=ab8dba7fab431ba76fb971071224e624282d93c1"
}

inputs = {
  hub = {
    git_ref   = "ab8dba7fab431ba76fb971071224e624282d93c1"
    bbd_draft = false
  }

  meshstack = {
    owning_workspace_identifier = "m25-platform"
  }

  azure_tenant_id = include.platform.locals.platform.azure.aadTenantId
  azure_location  = dependency.networking.outputs.hub_location

  # at likvid bank we only offer hub connectivity in the "corp" landing zones
  azure_scope = dependency.corp_online.outputs.corp_id

  azure_hub_scope                 = "/subscriptions/${dependency.networking.outputs.hub_subscription}"
  azure_hub_subscription_id       = dependency.networking.outputs.hub_subscription
  azure_hub_resource_group_name   = dependency.networking.outputs.hub_rg
  azure_hub_vnet_name             = dependency.networking.outputs.hub_vnet
  azure_backplane_subscription_id = dependency.networking.outputs.hub_subscription

  backplane_name = "likvid-azure-spoke-network"
}

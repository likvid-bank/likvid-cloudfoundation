include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization_hierarchy" {
  config_path = "../../organization-hierarchy"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  tenant_id           = "${include.platform.locals.platform.azure.aadTenantId}"
  # The backplane's identity and resource group live in the platform subscription.
  subscription_id     = "${include.platform.locals.platform.azure.subscriptionId}"
  storage_use_azuread = true
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "m25-platform"
}

EOF
}

generate "versions_override" {
  path      = "versions_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.26.8 finds the meshStack CLI profile by its endpoint.
      version = ">= 0.26.8"
    }
  }
}
EOF
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
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
    owning_workspace_identifier = "m25-platform"
  }

  azure_tenant_id = include.platform.locals.platform.azure.aadTenantId

  # Every landing zone may order a model, like a storage account.
  azure_scope    = dependency.organization_hierarchy.outputs.landingzones_id
  azure_location = "germanywestcentral"

  backplane_name = "likvid-azure-ai-llm"
}

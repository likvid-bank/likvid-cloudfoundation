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

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
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

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/storage-account?ref=2a47e2f6e0ec880c5d16c65746cfaffe7a46fd9b"
}

inputs = {
  hub = {
    git_ref   = "2a47e2f6e0ec880c5d16c65746cfaffe7a46fd9b"
    bbd_draft = false
  }

  meshstack = {
    owning_workspace_identifier = "m25-platform"
  }

  azure_tenant_id       = include.platform.locals.platform.azure.aadTenantId
  azure_subscription_id = "bd4b0c49-52bf-4b2b-a6ad-065a691591eb" # managed by meshStack (https://panel.demo.meshcloud.io/#/w/m25-platform/p/quickstart-infra-likvid/i/azure.meshcloud-azure-dev/overview/azure)
  azure_scope           = dependency.organization_hierarchy.outputs.landingzones_id
  azure_location        = "germanywestcentral"

  backplane_name = "likvid-azure-storage-account"

  workspace_tag_to_copy = "BusinessUnit"
}

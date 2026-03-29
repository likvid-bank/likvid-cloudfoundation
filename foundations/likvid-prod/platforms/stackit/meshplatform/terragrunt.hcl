include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

locals {
  # Pin hub ref for both module source and BBD implementation ref_name
  hub_git_ref = "main"
  token       = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  region                = "eu01"
  service_account_token = "${local.token}"
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/stackit/ske?ref=${local.hub_git_ref}"
}

inputs = {
  hub = {
    git_ref = local.hub_git_ref
  }

  meshstack = {
    owning_workspace_identifier = "admin"
  }

  ske = {
    platform_identifier = "ske1"
    location_identifier = "sovereign"

    base_url               = "https://api.ske-demo.d2695c1f95.s.ske.eu01.onstackit.cloud"
    disable_ssl_validation = true
    namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"
  }

  stackit_project_id = "272f2ba5-fa0a-4b8b-8ceb-e68165a87914"
  cluster_name       = "ske-demo"
  region             = "eu01"
}

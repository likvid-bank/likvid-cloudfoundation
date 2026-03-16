include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

locals {
  hub_git_ref = "main"
}

dependency "meshplatform" {
  config_path = "../../meshplatform"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/stackit/ske/starterkit?ref=${local.hub_git_ref}"
}

inputs = {
  hub = {
    git_ref = local.hub_git_ref
  }

  meshstack = {
    owning_workspace_identifier = "admin"
  }

  starterkit = {
    full_platform_identifier = "ske1"

    landing_zone_dev_identifier  = "ske1-default"
    landing_zone_prod_identifier = "ske1-default"

    git_repo_definition_uuid         = "" # TODO: fill after git-repo BBD is deployed
    git_repo_definition_version_uuid = "" # TODO: fill after git-repo BBD is deployed
  }

  project_tags_yaml = yamlencode({
    dev = {
      environment = ["dev"]
    }
    prod = {
      environment = ["prod"]
    }
  })
}

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

dependency "github_connector_backplane" {
  config_path = "../github-connector/backplane"
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
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aks/starterkit?ref=${local.hub_git_ref}"
}

inputs = {
  hub = {
    git_ref = local.hub_git_ref
  }

  meshstack = {
    owning_workspace_identifier = "admin"
  }

  aks = dependency.meshplatform.outputs.aks

  github = {
    org                        = "likvid-bank"
    app_id                     = "1776290"
    app_installation_id        = "80774688"
    app_pem_file               = get_env("GITHUB_APP_PEM_FILE")
    connector_config_tf_base64 = base64encode(dependency.github_connector_backplane.outputs.config_tf)
  }

  postgresql = {}

  project_tags_yaml = yamlencode({
    dev = {
      environment          = ["dev"]
      LandingZoneClearance = ["container-platform"]
      Schutzbedarf         = ["public"]
    }
    prod = {
      environment          = ["prod"]
      LandingZoneClearance = ["container-platform"]
      Schutzbedarf         = ["public"]
    }
  })
}

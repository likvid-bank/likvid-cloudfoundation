include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "meshstack" {
  config_path = "../meshstack"
  mock_outputs = {
    owning_workspace_identifier = "devops-platform"
    subscription_id             = "00000000-0000-0000-0000-000000000000"
  }
}

dependency "platform" {
  config_path = "../meshstack/platform"
  mock_outputs = {
    owned_by_workspace       = "devops-platform"
    full_platform_identifier = "aks-namespace.global"
    landing_zone_identifiers = {
      dev  = "aks-namespace-dev"
      prod = "aks-namespace-prod"
    }
  }
}

dependency "connector_backplane" {
  config_path = "../connector/backplane"
  mock_outputs = {
    config_tf = "mock"
  }
}

locals {
  hub = {
    git_ref   = "281007cc070cf6f088a325de30c34f3ec0e45b24"
    bbd_draft = true
  }
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

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.platform.outputs.owned_by_workspace
  }

  hub = local.hub

  github = {
    org                 = "likvid-bank"
    app_id              = "654209"
    app_installation_id = "44437049"
    app_pem_file        = get_env("GITHUB_APP_PEM_FILE")
  }

  connector_config_tf = dependency.connector_backplane.outputs.config_tf

  full_platform_identifier  = dependency.platform.outputs.full_platform_identifier
  landing_zone_identifiers  = dependency.platform.outputs.landing_zone_identifiers
  github_template_repo_path = "likvid-bank/aks-app-template"
  apps_base_domain          = "likvid-aks.msh.host"

  project_tags = {
    dev = {
      "environment"          = ["dev"]
      "LandingZoneClearance" = ["cloud-native"]
      "Schutzbedarf"         = ["internal"]
      "projectOwner"         = ["Platform Team"]
    }
    prod = {
      "environment"          = ["prod"]
      "LandingZoneClearance" = ["cloud-native"]
      "Schutzbedarf"         = ["public"]
      "projectOwner"         = ["Platform Team"]
    }
  }
}

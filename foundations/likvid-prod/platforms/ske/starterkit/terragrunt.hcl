include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "meshstack" {
  config_path = "../meshstack"
  mock_outputs = {
    owning_workspace_identifier = "mock-workspace"
  }
}

dependency "platform" {
  config_path = "../meshstack/platform"
  mock_outputs = {
    full_platform_identifier = "mock-platform"
    landing_zone_identifiers = {
      dev  = "mock-lz-dev"
      prod = "mock-lz-prod"
    }
  }
}

dependency "git" {
  config_path = "../git"
  mock_outputs = {
    forgejo_token        = "mock-token"
    forgejo_base_url     = "https://mock-git-instance.git.onstackit.cloud"
    forgejo_organization = "mock-org"
  }
}

locals {
  hub = {
    # TODO version pin and change bbd_draft to false once dev is completely done
    git_ref   = "main"
    bbd_draft = true
  }
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/ske/ske-starterkit?ref=${local.hub.git_ref}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

inputs = {
  meshstack = {
    owning_workspace_identifier = dependency.meshstack.outputs.owning_workspace_identifier
  }
  hub = local.hub

  full_platform_identifier = dependency.platform.outputs.full_platform_identifier
  landing_zone_identifiers = dependency.platform.outputs.landing_zone_identifiers

  forgejo_token        = dependency.git.outputs.forgejo_token
  forgejo_base_url     = dependency.git.outputs.forgejo_base_url
  forgejo_organization = dependency.git.outputs.forgejo_organization

  # TODO provision this from public https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer
  git_repository_template_path = "likvid/starterkit-template-stackit-ai-summarizer"

  project_tags = {
    owner_tag_key = "projectOwner"

    dev = merge(dependency.meshstack.outputs.required_project_tags, {
      "environment"  = ["dev"]
      "Schutzbedarf" = ["internal"] # overwrites default
    })
    prod = merge(dependency.meshstack.outputs.required_project_tags, {
      "environment" = ["prod"]
    })
  }

  tags                     = {}
  notification_subscribers = []
}

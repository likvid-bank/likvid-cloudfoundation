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

dependency "kubernetes" {
  config_path = "../kubernetes"
  mock_outputs = {
    kube_host              = "https://mock-kube-host"
    cluster_ca_certificate = "bW9jaw=="
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
    cluster_kubeconfig     = "apiVersion: v1"
  }
}

locals {
  hub = {
    # TODO version pin and change bbd_draft to false once dev is completely done
    git_ref   = "feature/ske-starter-kit-harbor-integration"
    bbd_draft = true
  }
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
  meshstack = dependency.meshstack.outputs
  hub       = local.hub

  full_platform_identifier = dependency.platform.outputs.full_platform_identifier
  landing_zone_identifiers = dependency.platform.outputs.landing_zone_identifiers

  forgejo_token        = dependency.git.outputs.forgejo_token
  forgejo_base_url     = dependency.git.outputs.forgejo_base_url
  forgejo_organization = dependency.git.outputs.forgejo_organization

  cluster_host           = dependency.kubernetes.outputs.kube_host
  cluster_ca_certificate = dependency.kubernetes.outputs.cluster_ca_certificate
  client_certificate     = dependency.kubernetes.outputs.client_certificate
  client_key             = dependency.kubernetes.outputs.client_key
  cluster_kubeconfig     = dependency.kubernetes.outputs.cluster_kubeconfig

  stackit_harbor_registry            = "registry.onstackit.cloud"
  stackit_harbor_project             = "stackit_kubernetes_platform" # Note: this project name is globally shared across all STACKIT, so maybe we should have used 'likvid-ske' as some prefix?
  stackit_harbor_image_name          = "ai-summarizer"
  stackit_harbor_push_robot_user     = get_env("STACKIT_HARBOR_PUSH_ROBOT_USER")
  stackit_harbor_push_robot_password = get_env("STACKIT_HARBOR_PUSH_ROBOT_PASSWORD")

  repo_clone_addr = "https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git"

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

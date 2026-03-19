include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "meshstack" {
  config_path                             = "../meshstack"
  skip_outputs                            = get_terraform_command() == "init"
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    owning_workspace_identifier = "mock-workspace"
    required_project_tags       = {}
    stackit_project_id          = "00000000-0000-0000-0000-000000000000"
  }
}

dependency "platform" {
  config_path                             = "../meshstack/platform"
  skip_outputs                            = get_terraform_command() == "init"
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    full_platform_identifier = "mock-platform"
    landing_zone_identifiers = {
      dev  = "mock-lz-dev"
      prod = "mock-lz-prod"
    }
  }
}

dependency "git" {
  config_path                             = "../git"
  skip_outputs                            = get_terraform_command() == "init"
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    forgejo_token        = "mock-token"
    forgejo_base_url     = "https://mock-git-instance.git.onstackit.cloud"
    forgejo_organization = "mock-org"
  }
}

dependency "kubernetes" {
  config_path                             = "../kubernetes"
  skip_outputs                            = get_terraform_command() == "init"
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    kubeconfig = {
      current-context = "mock-context"
      clusters = [
        {
          name = "mock-cluster"
          cluster = {
            server                     = "https://mock-kube-host"
            certificate-authority-data = "bW9jaw=="
          }
        }
      ]
      users = [
        {
          name = "mock-user"
          user = {
            client-certificate-data = "bW9jaw=="
            client-key-data         = "bW9jaw=="
          }
        }
      ]
      contexts = [
        {
          name = "mock-context"
          context = {
            cluster = "mock-cluster"
            user    = "mock-user"
          }
        }
      ]
    }
  }
}

dependency "dns" {
  config_path                             = "../dns"
  skip_outputs                            = get_terraform_command() == "init"
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    zone_name = "mock-zone.stackit.run"
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

provider "stackit" {
  default_region      = "eu01"
  service_account_key = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF
}

inputs = {
  meshstack = dependency.meshstack.outputs
  hub       = local.hub

  full_platform_identifier = dependency.platform.outputs.full_platform_identifier
  landing_zone_identifiers = dependency.platform.outputs.landing_zone_identifiers

  kubeconfig = dependency.kubernetes.outputs.kubeconfig

  forgejo_token        = dependency.git.outputs.forgejo_token
  forgejo_base_url     = dependency.git.outputs.forgejo_base_url
  forgejo_organization = dependency.git.outputs.forgejo_organization

  stackit_project_id          = dependency.meshstack.outputs.stackit_project_id
  stackit_service_account_key = get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY")

  # Note: the Harbor project name is globally shared across all STACKIT,
  # so maybe we should have used 'likvid-ske' as some prefix?
  stackit_harbor_project = "stackit_kubernetes_platform"

  # No way to provision those robot users with TF at the moment :(
  stackit_harbor_push_robot_user     = get_env("STACKIT_HARBOR_PUSH_ROBOT_USER")
  stackit_harbor_push_robot_password = get_env("STACKIT_HARBOR_PUSH_ROBOT_PASSWORD")
  stackit_harbor_pull_robot_user     = get_env("STACKIT_HARBOR_PULL_ROBOT_USER")
  stackit_harbor_pull_robot_password = get_env("STACKIT_HARBOR_PULL_ROBOT_PASSWORD")

  # Template name and base template repository should align
  template_name           = "ai-summarizer"
  template_repo_clone_url = "https://github.com/likvid-bank/starterkit-template-stackit-ai-summarizer.git"
  dns_zone_name           = dependency.dns.outputs.zone_name
  add_random_name_suffix  = false

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
}

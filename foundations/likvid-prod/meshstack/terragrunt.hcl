include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "aws_bootstrap" {
  config_path = "../platforms/aws/bootstrap"
}

dependency "azure_meshplatform" {
  config_path = "../platforms/azure/meshplatform"
}

dependency "azure_sandbox_landingzone" {
  config_path = "../platforms/azure/landingzones/sandbox"
}

terraform {
  source = "${get_repo_root()}//kit/foundation/meshstack"

  # We authentication against aws so we can fetch remote_state from S3 for the aws plattform
  # todo: we should source that from a foundation.yml somehow?
  extra_arguments "profile" {
    commands = [
      "init",
      "apply",
      "plan",
      "import",
      "state"
    ]

    env_vars = get_env("CI", "false") == "true" ? {} : {
      # activate a local CLI profile when not in CI
      AWS_PROFILE = "likvid-prod"
    }
  }
}

locals {
  azure = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/azure/README.md"))[0]).azure
  aws   = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/aws/README.md"))[0]).aws

  bucket   = "likvid-tf-state"
  key      = "meshstack.tfstate"
  region   = "eu-central-1"
  role_arn = "arn:aws:iam::490004649140:role/OrganizationAccountAccessRole"
  profile  = get_env("CI", "false") == "true" ? null : "likvid"
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket   = local.bucket
    key      = local.key
    region   = local.region
    role_arn = local.role_arn
    profile  = local.profile
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azuread" {
  tenant_id       = "${local.azure.aadTenantId}"
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}

provider "github" {
  owner = "likvid-bank"


  %{if try(get_env("CI", "false") == "true")}
  app_auth {
    id              = "1776290"
    installation_id = "80774688"
    # pem_file sourced from env var GITHUB_APP_PEM_FILE
  }
  %{endif}

}
EOF
}

inputs = {
  meshstack_api = {
    endpoint = "https://federation.demo.meshcloud.io"
    username = "likvid-prod"
    password = get_env("MESHSTACK_API_PASSWORD")
  }

  meshpanel_base_url = "https://panel.demo.meshcloud.io"

  demo_gitops = {
    repository = "static-website-assets"
    // todo: an API for setting up API keys would be sooo nice
    meshstack_api_key_id     = "253eb2f8-7589-471b-83f5-0e42312bf98f"
    meshstack_api_key_secret = get_env("MESHSTACK_API_KEY_STATIC_WEBSITE_ASSETS")
    aws_sso_instance_arn     = dependency.aws_bootstrap.outputs.identity_store_arn
    aws_identity_store_id    = dependency.aws_bootstrap.outputs.identity_store_id
    gha_aws_role_to_assume   = "arn:aws:iam::702461728527:role/likvid-static-website-assets-github-action-role"
  }

  # Uncomment to enable Azure M25 platform setup
  azure_m25_platform = {
    platform_identifier = "azure-m25"
    display_name        = "Azure M25"
    description         = "Microsoft Azure cloud platform managed by the M25 Platform Team. Provides access to Azure services with M25-specific governance and policies."
    documentation_url   = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/azure/meshplatform.html"
    location_ref_name   = "meshcloud-azure-dev" # Reference to a meshLocation defined in meshStack

    tenant_id            = dependency.azure_meshplatform.outputs.azure_ad_tenant_id
    replicator_auth_type = "WORKLOAD_IDENTITY"
    replicator_client_id = dependency.azure_meshplatform.outputs.replicator_credentials.Application_Client_ID
    replicator_object_id = dependency.azure_meshplatform.outputs.replicator_credentials.Enterprise_Application_Object_ID

    subscription_owner_object_ids = [
      # todo: should be changed to a group instead of replicator object ID
      dependency.azure_meshplatform.outputs.replicator_credentials.Enterprise_Application_Object_ID
    ]

    subscription_name_pattern = "#{workspaceIdentifier}.#{projectIdentifier}"
    group_name_pattern        = "#{workspaceIdentifier}.#{projectIdentifier}-#{platformGroupAlias}"

    azure_role_mappings = [
      {
        project_role_ref = { name = "admin" }
        azure_role       = { alias = "Owner", id = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635" }
      },
      {
        project_role_ref = { name = "user" }
        azure_role       = { alias = "Contributor", id = "b24988ac-6180-42a0-ab88-20f7382dd24c" }
      },
      {
        project_role_ref = { name = "reader" }
        azure_role       = { alias = "Reader", id = "acdd72a7-3385-48ef-bd42-f606fba81ae7" }
      }
    ]

    sandbox_landing_zone = {
      identifier                    = "azure-m25-sandbox"
      display_name                  = "Azure M25 Sandbox"
      description                   = "Sandbox environment for M25 developers to experiment with Azure services"
      parent_management_group_id    = basename(dependency.azure_sandbox_landingzone.outputs.sandbox_id)
      automate_deletion_approval    = false
      automate_deletion_replication = false
    }
  }
}



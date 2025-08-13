include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "aws_bootstrap" {
  config_path = "../platforms/aws/bootstrap"
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
}

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
  alias = "static_website_assets"
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "253eb2f8-7589-471b-83f5-0e42312bf98f"
  apisecret = "${get_env("MESHSTACK_API_KEY_STATIC_WEBSITE_ASSETS")}"
}

provider "meshstack" {
  alias = "online_banking_app"
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "cf4d794d-5176-44eb-9e69-ad80ce9bfedc"
  apisecret = "${get_env("MESHSTACK_API_KEY_ONLINE_BANKING_APP")}"
}

provider "meshstack" {
  alias = "sap_core_platform"
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "7a309ce7-439e-4bdb-b75f-e5c4b001b349"
  apisecret = "${get_env("MESHSTACK_API_KEY_SAP_CORE_PLATFORM")}"
}


provider "meshstack" {
  alias = "likvid_gov_guard"
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "924588a3-2e6e-4afd-910e-8d867a587551"
  apisecret = "${get_env("MESHSTACK_API_KEY_LIKVID_GOV_GUARD")}"
}
EOF
}

inputs = {
  meshstack_api = {
    endpoint = "https://federation.demo.meshcloud.io"
    username = "likvid-prod"
    password = get_env("MESHSTACK_API_PASSWORD")

  }
}

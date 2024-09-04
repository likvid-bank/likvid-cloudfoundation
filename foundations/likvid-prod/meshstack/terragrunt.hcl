terraform {
  source = "${get_repo_root()}//kit/foundation/meshstack"

  # We authentication against aws so we can fetch remote_state from S3 for the aws plattform
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

#TODO: maybe move this to an own bucket or use a different prefix
# we store foundation module terraform state with the aws platform state

locals {
  azure = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/azure/README.md"))[0]).azure
  aws   = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../platforms/aws/README.md"))[0]).aws
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
  apikey    = ""
  apisecret = "${get_env("MESHSTACK_API_KEY_STATIC_WEBSITE_ASSETS")}"
}

provider "meshstack" {
  alias = "online_banking_app"
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = ""
  apisecret = "${get_env("MESHSTACK_API_KEY_ONLINE_BANKING_APP")}"
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

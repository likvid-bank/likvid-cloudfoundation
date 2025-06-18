include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# exclude bootstrap module for all operations when run in a stack
# bootstrap modules must be run individually via `terragrunt apply`
exclude {
  if      = true
  actions = ["all"]
}

terraform {
  source = "${get_repo_root()}//kit/ovh/bootstrap"
}


locals {
  application_key    = get_env("OVH_APPLICATION_KEY")
  application_secret = get_env("OVH_APPLICATION_SECRET")
  consumer_key       = get_env("OVH_CONSUMER_KEY")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "ovh" {
    endpoint        = "ovh-eu"
    application_key = "${local.application_key}"
    consumer_key    = "${local.consumer_key}"
    application_secret = "${local.application_secret}"
    }
EOF
}

inputs = {
  platform_admins = [
    { email = "fnowarre@meshcloud.io" },
    { email = "jrudolph@meshcloud.io" },
    { email = "malhussan@meshcloud.io" }
  ]
}

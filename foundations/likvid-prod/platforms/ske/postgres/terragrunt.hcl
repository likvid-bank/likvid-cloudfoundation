include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

include "hub" {
  path   = "../platform/hub.hcl"
  expose = true
}

# Runs by hand as the STACKIT CLI login, whose token lives a few minutes:
# `STACKIT_SERVICE_ACCOUNT_TOKEN=$(stackit auth get-access-token) terragrunt apply`. Skip from CI.
exclude {
  if      = true
  actions = ["plan", "test"]
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<PROVIDER
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "devops-platform"
}

provider "stackit" {
  service_account_token = var.stackit_access_token
  default_region        = "eu01"
  experiments           = ["iam"]
}
PROVIDER
}

inputs = {
  hub                  = include.hub.locals
  stackit_access_token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN", "")
}

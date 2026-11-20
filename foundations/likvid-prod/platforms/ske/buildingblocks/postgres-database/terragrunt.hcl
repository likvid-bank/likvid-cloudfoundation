include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
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
}
PROVIDER
}

inputs = {
  draft = true

  # The branch lets a fix reach a released version with the next run; pin a commit after the merge.
  building_block_git_ref = "feature/agentic-factory-demo"
  meshstack_hub_git_ref  = "e9351060d9a87b1a7e4ea5f8f2bd47016e1d691c"

  stackit_access_token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

# Needs STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY for an SKE admin kubeconfig. Skip from CI; run
# manually after sourcing setup-env.sh.
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
  service_account_key = var.stackit_ske_service_account_key
  default_region      = "eu01"
  experiments         = ["ske"]
}
PROVIDER
}

inputs = {
  draft = false

  # The branch lets a fix reach a released version with the next run; pin a commit after the merge.
  building_block_git_ref = "feature/agentic-factory-demo"
  meshstack_hub_git_ref  = "e9351060d9a87b1a7e4ea5f8f2bd47016e1d691c"

  stackit_ske_service_account_key = get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY")
}

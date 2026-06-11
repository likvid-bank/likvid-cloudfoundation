include "common" {
  path = find_in_parent_folders("common.hcl")
}

# requires STACKIT_SERVICE_ACCOUNT_TOKEN — skip from `terragrunt test --all` in CI; run manually when credentials are available
exclude {
  if      = true
  actions = ["test"]
}

terraform {
  source = "${get_repo_root()}//kit/stackit/buildingblocks/projects/buildingblock"
}

locals {
  token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN", "")
}


inputs = {
  token = local.token
}

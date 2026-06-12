include "common" {
  path = find_in_parent_folders("common.hcl")
}

# requires STACKIT_SERVICE_ACCOUNT_TOKEN + AWS credentials (S3 backend) — skip from CI; run manually when credentials are available
exclude {
  if      = true
  actions = ["plan", "test"]
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

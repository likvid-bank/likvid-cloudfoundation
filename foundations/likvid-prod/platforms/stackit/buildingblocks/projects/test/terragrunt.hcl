include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "${get_repo_root()}//kit/stackit/buildingblocks/projects/buildingblock"
}

locals {
  token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")
}


inputs = {
  token = local.token
}

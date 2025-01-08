terraform {
  source = "${get_repo_root()}//kit/stackit/buildingblocks/projects/buildingblock"
}

locals {
  token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")
}


inputs = {
  token = local.token
}

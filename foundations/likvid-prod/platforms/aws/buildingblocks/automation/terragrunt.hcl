include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/aws/buildingblocks/automation"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

dependency "organization" {
  config_path = "../../organization"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}
EOF
}

inputs = {
  foundation                                       = "likvid-prod"
  building_block_backend_account_service_user_name = "buildingblock-cf-deploy"
  building_block_backend_account_id                = dependency.bootstrap.outputs.management_account_id
  building_block_target_ou_ids                     = [dependency.organization.outputs.landingzones_ou_id]
  building_block_target_account_access_role_name   = "LikvidBuildingBlockServiceRole"
}

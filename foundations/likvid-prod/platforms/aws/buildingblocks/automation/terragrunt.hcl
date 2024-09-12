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
  alias  = "management"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${include.platform.locals.platform.aws.accountId}:role/OrganizationAccountAccessRole"
  }
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}

provider "aws" {
  alias  = "tf-backend"
  region = "eu-central-1"
  assume_role {
    role_arn = "arn:aws:iam::${dependency.bootstrap.outputs.tf_backend_account_id}:role/OrganizationAccountAccessRole"
  }
  allowed_account_ids = ["${dependency.bootstrap.outputs.tf_backend_account_id}"]
}
EOF
}

inputs = {
  foundation                                       = "likvid-prod"
  building_block_backend_account_service_user_name = "buildingblock-cf-deploy"
  building_block_backend_account_id                = dependency.bootstrap.outputs.tf_backend_account_id
  building_block_target_ou_ids                     = [dependency.organization.outputs.landingzones_ou_id]
  building_block_target_account_access_role_name   = "LikvidBuildingBlockServiceRole"
}

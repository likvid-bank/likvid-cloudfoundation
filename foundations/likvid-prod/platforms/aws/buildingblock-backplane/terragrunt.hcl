# this is directly deployed with terragrunt because iam not not sure how to restructure it
# the account is deployed with meshstack called "buildingblock-backend"
# and its only for a demo scenario. We will need to refactor this to a module in the future with
# more time

#include "platform" {
#  path   = find_in_parent_folders("platform.hcl")
#  expose = true
#}

terraform {
  source = "${get_repo_root()}//kit/aws/buildingblocks/automation"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket  = "likvid.bb-tf-backend"
    key     = "terraform/buildingblock-backplane/terraform.tfstate"
    region  = "eu-central-1"
    profile = "management" #TODO fix permissions
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "aws" {
  region = "eu-central-1"

  profile = "management" #TODO fix permissions
}
EOF
}

inputs = {
  building_block_backend_bucket_name               = "likvid.bb-tf-backend" # Matches the terragrunt managed bucket
  building_block_backend_account_service_user_name = "likvid-buildingblock-cf-deploy"
  building_block_backend_account_id                = "702461728527"

  building_block_target_ou_ids                   = ["ou-rpqz-ysvbxywo", "ou-rpqz-iq2j0zhi"]
  building_block_target_account_access_role_name = "LikvidBuildingBlockServiceRole"
}

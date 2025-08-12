include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "backplane" {
  config_path = "../backplane"
}

# NOTE: this test is slow and needs ~10 minutes to complete.
inputs = {
  account_id      = "331702097822"
  assume_role_arn = dependency.backplane.outputs.backplane_role_arn
}

# this is a manual test, so do not support any terragrunt stack action at all
exclude {
  if      = true
  actions = ["all"]
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/opt-in-region/buildingblock?ref=2fbbc17e4cc85f89d16d525c8654b760ebff53fc"

  extra_arguments "env" {
    commands  = ["test", "plan", "apply", "destroy"]
    arguments = []
    env_vars = {
      AWS_REGION            = "eu-central-1"
      AWS_ACCESS_KEY_ID     = dependency.backplane.outputs.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = dependency.backplane.outputs.aws_secret_access_key
    }
  }
}


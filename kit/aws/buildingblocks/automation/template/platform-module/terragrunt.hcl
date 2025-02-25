include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "${path_relative_from_include()}/bootstrap"
}

terraform {
  source = "${get_repo_root()}//kit/aws/buildingblock-backplane/bucket"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "aws" {
  region = "eu-central-1"
  access_key = "${dependency.bootstrap.outputs.cloudfoundation_tf_deploy_user_iam_access_key_id}"
  secret_key = "${dependency.bootstrap.outputs.cloudfoundation_tf_deploy_user_iam_access_key_secret}"

## We are using Automation account here, since meshStack already set up a trust to this account
  assume_role {
    role_arn     = "arn:aws:iam::579066991346:role/${include.platform.locals.active_role.default}"
    session_name = "cloudfoundation_tf_deploy"
  }
}
EOF
}

inputs = {
  foundation_name = "meshcloud-XXXXX"
  region          = "eu-central-1"
}
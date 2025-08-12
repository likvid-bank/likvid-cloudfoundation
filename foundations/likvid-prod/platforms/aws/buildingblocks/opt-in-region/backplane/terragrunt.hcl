include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "../../../bootstrap"
}

dependency "organization" {
  config_path = "../../../organization"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"
  alias = "backplane"
  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.automation_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "cloudfoundation_tf_deploy"
  }
}

provider "aws" {
  region = "eu-central-1"
  alias = "management"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/opt-in-region/backplane?ref=2fbbc17e4cc85f89d16d525c8654b760ebff53fc"
}

inputs = {
}

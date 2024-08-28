include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../../organization"
}

terraform {
  source = "${get_repo_root()}//kit/aws/landingzones/cloud-native"
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
  parent_ou_id = dependency.organization.outputs.landingzones_ou_id
}


# arn:aws:iam::aws:policy/AdministratorAccess
# arn:aws:iam::aws:policy/PowerUserAccess
# arn:aws:iam::aws:policy/ReadOnlyAccess

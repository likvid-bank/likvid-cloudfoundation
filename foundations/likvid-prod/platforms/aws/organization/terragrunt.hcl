include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

terraform {
  source = "${get_repo_root()}//kit/aws/organization"
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
  parent_ou_name                   = "likvid"
  automation_account_email         = "aws+automation@meshcloud.io"
  network_management_account_email = "aws+network.management@meshcloud.io"
  management_account_email         = "aws+management@meshcloud.io"
  meshstack_account_email          = "aws+meshcloud@meshcloud.io"
}

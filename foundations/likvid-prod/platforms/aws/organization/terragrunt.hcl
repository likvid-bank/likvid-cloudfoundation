include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
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
  automation_account_email         = "aws+automation-acc@meshcloud.io"
  network_management_account_email = "likvid-networking@meshcloud.io"
  management_account_email         = "aws+management-acc@meshcloud.io"
  meshstack_account_email          = "aws+meshstack-acc@meshcloud.io"
  admin_users                      = include.platform.locals.foundation_pam.foundation_admins
}

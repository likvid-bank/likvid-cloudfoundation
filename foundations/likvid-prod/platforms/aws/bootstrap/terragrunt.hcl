include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/aws/bootstrap"
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
  aws_root_account_id = include.platform.locals.platform.aws.accountId

  foundation            = "likvid-prod" 
  github_repo_full_name = "likvid-bank/likvid-cloudfoundation"

  parent_ou_id         = "ou-rpqz-vx54f60i"
  validation_role_name = include.platform.locals.roles.validation

  platform_engineers_group = {
    name = "${include.platform.locals.cloudfoundation}-foundation-platform-engineers"
    members = concat(
      include.platform.locals.foundation_pam.foundation_admins,
      include.platform.locals.foundation_pam.foundation_engineers
    )
  }
}

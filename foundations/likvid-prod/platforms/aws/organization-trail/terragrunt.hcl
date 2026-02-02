include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/aws/organization-trail"
}

dependency "organization" {
  config_path = "../organization"
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  alias = "org_mgmt"
  region = "eu-central-1"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}

provider "aws" {
  alias  = "audit"
  region = "eu-central-1"

  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.management_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "likvid_cloudfoundation_tf_deploy"
  }
}
EOF
}

inputs = {
  trail_name     = "likvid-prod-trail"
  s3_bucket_name = "likvid-prod-organization-trail-bucket"
}

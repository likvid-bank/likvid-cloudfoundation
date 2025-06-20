include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn     = "arn:aws:iam::495599748622:role/${include.platform.locals.active_role.meshstack_managed_account}"
    session_name = "cloudfoundation_tf_deploy"
  }
  allowed_account_ids = [
    "495599748622" # account created via meshstack (meshcloud-demo -> m25-platform workspace -> quickstart-infra-prod project)
  ]
}

EOF
}

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/aws/buildingblocks/s3_bucket/backplane?ref=v0.5.5"
}

inputs = {}

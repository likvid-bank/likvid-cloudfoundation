include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../../organization"
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/agentic-coding-sandbox/backplane/landingzone?ref=d709611025f677071308e6d0798bfbe6a47a1321"
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

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
    role_arn     = "arn:aws:iam::874618049110:role/${include.platform.locals.active_role.meshstack_managed_account}"
    session_name = "cloudfoundation_tf_deploy"
  }
  allowed_account_ids = [
    "874618049110" # account created via meshstack (meshcloud-demo -> m25-platform workspace -> quickstart-infra-likvid project)
  ]
}

EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/s3_bucket/backplane?ref=dae10261fe831dcc00a3a9a4fc6b3b00d9018da3"
}

inputs = {
  workload_identity_federation = {
    issuer   = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
    audience = "aws-workload-identity-provider:meshcloud-demo"
    subject  = "system:serviceaccount:meshcloud-demo:tfrunner-66ddc814-1e69-4dad-b5f1-3a5bce51c01f"
  }
}

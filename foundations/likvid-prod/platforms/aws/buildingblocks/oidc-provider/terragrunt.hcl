# The meshStack runner's OIDC provider in the automation account, shared by every AWS building
# block backplane deployed there.
#
# AWS registers one OIDC provider per issuer URL per account, so the runner's issuer fits into an
# account exactly once no matter how many backplanes federate through it. A backplane that created
# its own would fail with `EntityAlreadyExists` as soon as a second one arrived, and destroying it
# would break every other backplane in the account — so it is account infrastructure with its own
# state instead. See the hub's `.agents/references/aws-backplane.md#the-shared-oidc-provider`.
#
# It also cannot live inside the budget-alert unit: the hub's oidc-provider module requires aws
# provider 6.x, while the budget-alert module is still capped below 6.0.

include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Also carries this platform's remote_state, so the unit's state prefix matches its siblings.
include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../../organization"
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aws/oidc-provider?ref=917189efe5d6c9e0d65e41584104148260c155f7"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<PROVIDERS
provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.automation_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "cloudfoundation_tf_deploy"
  }
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
PROVIDERS
}

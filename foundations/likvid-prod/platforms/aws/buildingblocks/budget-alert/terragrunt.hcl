include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Also carries this platform's remote_state, so the unit's state prefix matches its siblings.
include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "organization" {
  config_path = "../../organization"
}

dependency "oidc_provider" {
  config_path = "../oidc-provider"
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

# Migration only, remove once this unit has been applied: the superseded backplane held its
# resources under this alias, and the pre-WIF IAM user cannot be destroyed while the provider
# configuration its state entry names is missing.
provider "aws" {
  alias  = "backplane"
  region = "eu-central-1"

  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.automation_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "cloudfoundation_tf_deploy"
  }
}

provider "aws" {
  alias               = "management"
  region              = "eu-central-1"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
PROVIDERS
}

inputs = {
  hub = {
    git_ref   = include.hub.locals.git_ref
    bbd_draft = include.hub.locals.bbd_draft
  }

  oidc_provider_arn = dependency.oidc_provider.outputs.arn
  target_ou_ids     = [dependency.organization.outputs.landingzones_ou_id]

  # DO NOT CHANGE. This is the name of the live StackSet and of the role it has already placed in
  # every landing zone account. Keeping it makes the migration an in-place trust-policy update
  # instead of a replacement.
  target_account_role_name = "building-block-budget-alert"

  # The platform team's workspace, which owns this foundation's building block definitions — the
  # workspace `smoke.hcl` also names. It has to match the workspace the hand-made definition this
  # unit imports is owned by, or the import cannot keep its uuid.
  owning_workspace_identifier = "devops-platform"

  smoke_test_tenant = {
    workspace          = "cloudf-oundation"
    platform_tenant_id = "934977584221"
  }
}

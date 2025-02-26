include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../organization"
}

dependency "landingzones_cloudnative" {
  config_path = "../landingzones/cloud-native"
}

dependency "landingzones_onprem" {
  config_path = "../landingzones/on-prem"
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  alias = "management"
  region = "eu-central-1"
  allowed_account_ids = ["${include.platform.locals.platform.aws.accountId}"]
}

provider "aws" {
  alias  = "automation"
  region = "eu-central-1"

  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.automation_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "likvid_cloudfoundation_tf_deploy"
  }
}

provider "aws" {
  alias  = "meshcloud"
  region = "eu-central-1"

  assume_role {
    role_arn     = "arn:aws:iam::${dependency.organization.outputs.meshstack_account_id}:role/${include.platform.locals.active_role.default}"
    session_name = "likvid_cloudfoundation_tf_deploy"
  }
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/aws/meshplatform"
}

inputs = {
  aws_sso_instance_arn                 = "arn:aws:sso:::instance/ssoins-69873586782ebb40"
  replicator_privileged_external_id    = "cb40852c-9274-496c-af18-f33a443e18ee"
  cost_explorer_privileged_external_id = "e78903bc-b591-47f8-907a-cae352e00c0e"
  support_root_account_via_aws_sso     = true

  management_account_service_role_name = "LikvidMeshfedServiceRole"
  meshcloud_account_service_user_name  = "likvid-meshfed-service-user"
  automation_account_service_role_name = "LikvidMeshfedAutomationRole"

  cost_explorer_management_account_service_role_name = "LikvidCostExplorerServiceRole"
  cost_explorer_meshcloud_account_service_user_name  = "likvid-cost-explorer-user"

  control_tower_enrollment_enabled = true
  control_tower_portfolio_id       = "port-bss2p4a4btut4"
  landing_zone_ou_arns = [
    dependency.organization.outputs.landingzones_ou_arn,
    dependency.landingzones_cloudnative.outputs.dev_ou_arn,
    dependency.landingzones_cloudnative.outputs.prod_ou_arn,
    dependency.landingzones_onprem.outputs.dev_ou_arn,
    dependency.landingzones_onprem.outputs.prod_ou_arn,
    "arn:aws:organizations::${include.platform.locals.platform.aws.accountId}:ou/o-0asb1bd1jb/ou-rpqz-iq2j0zhi" # likvid-mobile OU
  ]

  can_close_accounts_in_resource_org_paths = [
    # Ideally this should be restricted to specific landing zones, but that results in a 400 error from AWS.
    "${dependency.organization.outputs.org_id}/${dependency.organization.outputs.org_root_id}/*",
  ]

  create_access_keys = true
}
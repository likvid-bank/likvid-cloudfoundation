include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../organization"
}

dependency "organization_trail" {
  config_path = "../organization-trail"
}

dependency "cloud_native" {
  config_path = "../landingzones/cloud-native"
}

dependency "on_prem" {
  config_path = "../landingzones/on-prem"
}

dependency "bedrock" {
  config_path = "../landingzones/bedrock"
}

dependency "m25" {
  config_path = "../m25"
}

terraform {
  source = ".//."
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# No cloud provider needed — this module only renders local files.
EOF
}

inputs = {
  output_dir = get_terragrunt_dir()

  payer_account_id = include.platform.locals.platform.aws.accountId

  # organization
  org_id                = dependency.organization.outputs.org_id
  org_root_id           = dependency.organization.outputs.org_root_id
  parent_ou_id          = dependency.organization.outputs.parent_ou_id
  landingzones_ou_id    = dependency.organization.outputs.landingzones_ou_id
  management_account_id = dependency.organization.outputs.management_account_id
  networking_account_id = dependency.organization.outputs.networking_account_id
  automation_account_id = dependency.organization.outputs.automation_account_id
  meshstack_account_id  = dependency.organization.outputs.meshstack_account_id

  # SCP
  deny_cloudtrail_deactivation_policy_id = dependency.organization.outputs.deny_cloudtrail_deactivation_policy_id

  # landing zones
  cloud_native_ou_id      = dependency.cloud_native.outputs.cloud_native_ou_id
  cloud_native_dev_ou_id  = dependency.cloud_native.outputs.dev_ou_id
  cloud_native_prod_ou_id = dependency.cloud_native.outputs.prod_ou_id
  on_prem_dev_ou_id       = dependency.on_prem.outputs.dev_ou_id
  on_prem_prod_ou_id      = dependency.on_prem.outputs.prod_ou_id
  bedrock_ou_id           = dependency.bedrock.outputs.organizational_unit_id
  m25_platform_ou_id      = dependency.m25.outputs.m25_platform_ou_id

  # organization-trail
  org_trail_arn   = dependency.organization_trail.outputs.org_trail_arn
  trail_s3_bucket = dependency.organization_trail.outputs.s3_bucket
}

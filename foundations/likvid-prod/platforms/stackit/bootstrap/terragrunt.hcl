include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/stackit/bootstrap"
}

locals {
  token = get_env("STACKIT_SERVICE_ACCOUNT_TOKEN")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  region              = "eu01"
  service_account_token = "${local.token}"
}
EOF
}

inputs = {
  token           = local.token
  organization_id = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  platform_admins = [
    { subject = "fnowarre@meshcloud.io", role = "organization.member" },
    { subject = "jrudolph@meshcloud.io", role = "organization.member" },
    { subject = "malhussan@meshcloud.io", role = "organization.member" }
  ]
  platform_users = [
    { subject = "bschoor@meshcloud.io", role = "organization.auditor" },
    { subject = "sradzhabov@meshcloud.io", role = "organization.auditor" },
    { subject = "ckraus@meshcloud.io", role = "organization.auditor" },
    { subject = "ule@meshcloud.io", role = "organization.auditor" },
    { subject = "likvid-tom@meshcloud.io", role = "organization.auditor" },
    { subject = "likvid-anna@meshcloud.io", role = "organization.auditor" },
  { subject = "likvid-daniela@meshcloud.io", role = "organization.auditor" }]
}

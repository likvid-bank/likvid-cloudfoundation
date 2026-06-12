include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# exclude bootstrap module for all operations when run in a stack
# bootstrap modules must be run individually via `terragrunt apply`
exclude {
  if      = true
  actions = ["all"]
}

terraform {
  source = "./"
}

# for bootstrap, use user's local service account
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  region                = "eu01"
  enable_beta_resources = true
  experiments = ["iam"]
}
EOF
}

inputs = {
  organization_id = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  platform_admins = [
    { subject = "fnowarre@meshcloud.io", role = "organization.member" },
    { subject = "jrudolph@meshcloud.io", role = "organization.member" },
    { subject = "malhussan@meshcloud.io", role = "organization.member" }
  ]

  platform_users = [
    { subject = "ckraus@meshcloud.io", role = "organization.auditor" }
  ]
}

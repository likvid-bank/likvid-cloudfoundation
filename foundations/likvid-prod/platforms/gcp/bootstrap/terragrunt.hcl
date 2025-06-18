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

# todo: this is a bootstrap module, you typically want to set up a provider
# with user credentials (cloud CLI based authentication) here
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project     = "${include.platform.locals.platform.gcp.project}"
  billing_project = "${include.platform.locals.platform.gcp.project}"
  user_project_override = true
  region      = "europe-west3"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/bootstrap"
}

inputs = {
  foundation            = include.platform.locals.cloudfoundation
  foundation_project_id = include.platform.locals.platform.gcp.project
  billing_project_id    = include.platform.locals.platform.gcp.billingExport.project
  billing_account_id    = include.platform.locals.platform.gcp.billingAccount
  parent_folder_id      = "folders/493343334220"
  region                = "europe-west3"

  github_repo_full_name              = "likvid-bank/likvid-cloudfoundation"
  github_repo_enable_tf_state_access = true

  platform_engineers_group = {
    name = "${include.platform.locals.cloudfoundation}-foundation-platform-engineers"
    members = concat(
      include.platform.locals.pam.foundation_admins,
      include.platform.locals.pam.foundation_engineers
    )
    # note: we create groups in meshcloud.io directory, not in dev.meshcloud.io
    domain = "meshcloud.io"
  }

  tf_state_bucket_name = "foundation-likvid-prod-tf-states"

  service_account_name = "likvid-prod-deploy-user"
}

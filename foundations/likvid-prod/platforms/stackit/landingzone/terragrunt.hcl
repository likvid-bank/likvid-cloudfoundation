include "common" {
  path = find_in_parent_folders("common.hcl")
}

# requires STACKIT_ORG_SERVICE_ACCOUNT_KEY, which lives only in Vault and not as a GitHub secret —
# skip from CI; run manually after sourcing setup-env.sh
exclude {
  if      = true
  actions = ["plan", "test"]
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

inputs = {
  hub = {
    git_ref   = "a37222c8f71f3aa9a0d3e79908afc3250154771c"
    bbd_draft = false
  }

  # The account has to be an organization owner, for the reason given on `stackit_owner_email` in
  # main.tf. It lives in Vault under concourse/meshstack-dev/likvid-cloudfoundation.
  stackit_service_account_key = get_env("STACKIT_ORG_SERVICE_ACCOUNT_KEY")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

# The admin workspace, because the API keys of the control tower demo belong to `stackitcontrolto`.
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "likvid-cloud"
}
EOF
}

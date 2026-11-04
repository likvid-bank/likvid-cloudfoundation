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
    git_ref = "bcd02413d705fb52f5adfd5d19051ba2fdff97ce"
    # Other workspaces, such as `devops-platform`, may order only released versions of the service
    # account and federation definitions.
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

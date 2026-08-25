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
    git_ref   = "78421ef25f10c72f6501679e926f8c0191520cec"
    bbd_draft = true
  }

  # The account has to be an organization owner, for the reason given on `stackit_owner_email` in
  # main.tf. It lives in Vault under concourse/meshstack-dev/likvid-cloudfoundation.
  stackit_service_account_key = get_env("STACKIT_ORG_SERVICE_ACCOUNT_KEY")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

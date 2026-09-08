include "common" {
  path = find_in_parent_folders("common.hcl")
}

# requires STACKIT_ORG_SERVICE_ACCOUNT_KEY and the MESHSTACK_API_KEY_CONTROLTOWER_DEMO_* pair, which
# live only in Vault and not as GitHub secrets — skip from CI; run manually after sourcing setup-env.sh
exclude {
  if      = true
  actions = ["plan", "test"]
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

inputs = {
  hub = {
    git_ref   = "dd5aa6efdc52283021d2853ccc204be89778278f"
    bbd_draft = true
  }

  # The account has to be an organization owner, for the reason given on `stackit_owner_email` in
  # main.tf. It lives in Vault under concourse/meshstack-dev/likvid-cloudfoundation.
  stackit_service_account_key = get_env("STACKIT_ORG_SERVICE_ACCOUNT_KEY")

  # Admin-scoped key pair the Control Tower demo's ALZ definitions authenticate with. It cannot be
  # minted here — the deploy key holds ADM_APIKEY_LIST but not ADM_APIKEY_SAVE — so it is created in
  # the panel and stored in Vault next to the other meshStack keys.
  controltower_demo_admin_api_key    = get_env("MESHSTACK_API_KEY_CONTROLTOWER_DEMO_ID")
  controltower_demo_admin_api_secret = get_env("MESHSTACK_API_KEY_CONTROLTOWER_DEMO_SECRET")
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

include "common" {
  path = find_in_parent_folders("common.hcl")
}

# The backplane grants its automation identity org-scoped roles (iam.service-account-admin,
# iam.member-admin), which needs the STACKIT organization-owner key. That key lives only in Vault
# (concourse/meshstack-dev/likvid-cloudfoundation), not as a GitHub secret — so like the landingzone
# this unit is skipped in CI and applied manually after sourcing setup-env.sh with an org-owner key
# in STACKIT_SERVICE_ACCOUNT_KEY_PATH.
exclude {
  if      = true
  actions = ["plan", "test"]
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

inputs = {
  hub = include.hub.locals
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

provider "stackit" {
  experiments = ["iam"]
}
EOF
}

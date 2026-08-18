include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

# Hub coordinates live in hub.hcl (single source of truth).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

inputs = {
  hub = include.hub.locals

  # Organization-owner service account, shared with TCF so both foundations deploy the STACKIT
  # landing zone the same way. Organization owner is required here because `stackit_owner_email` is
  # a mailbox rather than this account itself — see the comment on that local in main.tf.
  #
  # It lives only in Vault (concourse/meshstack-dev/likvid-cloudfoundation, field
  # STACKIT_ORG_SERVICE_ACCOUNT_KEY), so CI cannot plan this unit until the same value exists as a
  # GitHub secret.
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

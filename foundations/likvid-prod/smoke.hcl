# Shared by every smoke test in this foundation — see the `hub` skill.
#
# Do not add `common.hcl` (its hooks only serve `plan`) or `tfstate.hcl`: either puts cloud
# credentials back into a run that should need none.

locals {
  meshstack = {
    endpoint = "https://federation.demo.meshcloud.io"

    # The CI API user, not the one the `ske` deployment units use: it is the meshStack credential
    # this repo already holds as an Actions secret, so a new smoke test needs no new secret.
    apikey = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"

    # Spelled out rather than looked up — the deployment units resolve the same value through
    # `data.meshstack_workspace`, and reaching for their state is what this file exists to avoid.
    workspace = "devops-platform"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "${local.meshstack.endpoint}"
  apikey    = "${local.meshstack.apikey}"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

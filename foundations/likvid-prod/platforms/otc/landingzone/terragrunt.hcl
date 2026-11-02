include "common" {
  path = find_in_parent_folders("common.hcl")
}

# requires OTC_ACCESS_KEY and OTC_SECRET_KEY, which live only in Vault and not as GitHub secrets —
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
    git_ref   = "e84b1dbc5b1306f8356044de9abb2e330bce0025"
    bbd_draft = true
  }

  otc_access_key = get_env("OTC_ACCESS_KEY")
  otc_secret_key = get_env("OTC_SECRET_KEY")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# The admin workspace, because this unit creates `otc-platform`.
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "likvid-cloud"
}
EOF
}

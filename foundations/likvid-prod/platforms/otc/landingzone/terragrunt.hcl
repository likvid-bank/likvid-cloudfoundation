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
    git_ref   = "1ee1eb0969cc332851f9427d8d35a1dfaf4269db"
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

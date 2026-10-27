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
  # The architecture is not on the hub's main branch yet.
  hub = {
    git_ref   = "5b3344e1734c46d3754b5cd6bf42b34f8bd08bd0"
    bbd_draft = true
  }

  otc_access_key = get_env("OTC_ACCESS_KEY")
  otc_secret_key = get_env("OTC_SECRET_KEY")
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

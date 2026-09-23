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
  # Sources the nested hub integrations that the building block registers. The architecture itself
  # is the local copy in ./stackit-landingzone.
  hub = {
    git_ref   = "103b8cf6cf4569f4e457e33f1407cb360d6f89a8"
    bbd_draft = true
  }

  # meshStack checks this commit out from GitHub, so it must be pushed. A change to the building
  # block code takes two commits: the change itself, then this pin moved onto it.
  buildingblock_git_ref = "a22b16e493e85006c6f867f88edcfa5e1daaf972"

  # The same organization-owner account as the live landingzone unit, see `stackit_owner_email` there.
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

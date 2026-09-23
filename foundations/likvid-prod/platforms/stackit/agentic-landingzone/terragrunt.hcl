include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

inputs = {
  # Sources the nested hub integrations that the building block registers. The architecture itself is
  # the local copy in this unit.
  hub = {
    git_ref   = "b70efaad7de7fccf2dcb513d94db6308295261a0"
    bbd_draft = true
  }

  # meshStack checks this commit out from GitHub, so it must be pushed. A change to the building
  # block code takes two commits: the change itself, then this pin moved onto it.
  buildingblock_git_ref = "83cd219eccf964381f168c36917d5d9e8dc9dcde"

  # The organization owner whose key the live landingzone unit uses. For this unit it needs the WIF
  # trust from the `workload_identity_federation` output instead.
  stackit_service_account_email = "bootstrap-sa-4yfw9wi8@sa.stackit.cloud"
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

include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

inputs = {
  hub = {
    git_ref   = "150c79a203ed5877d4ed91e4fc763104db4bb6dc"
    bbd_draft = true
  }
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

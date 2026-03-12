include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "ebeb67c1-aaa6-4fd5-9b0b-f70e975b7fef"
  apisecret = "${get_env("MESHSTACK_API_SECRET_STACKIT_IDP")}"
}
EOF
}

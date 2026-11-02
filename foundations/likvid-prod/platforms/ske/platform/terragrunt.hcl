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
  workspace = "devops-platform"
}
EOF
}

inputs = {
  hub_ref           = "3d02c067efcf0b6a12f2f33778e06d4c506f8cf1"
  forgejo_api_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}

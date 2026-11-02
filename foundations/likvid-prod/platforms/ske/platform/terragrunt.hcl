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
  hub_ref           = "8ddba8e0c2a836929bf5d425688d364e26f2cd12"
  forgejo_api_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}

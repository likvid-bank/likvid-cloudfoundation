include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

inputs = {
  hub = {
    # Moves to a main commit once meshcloud/meshstack-hub#490 merges.
    git_ref   = "feature/stackit-lz-workshop-dec"
    bbd_draft = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "likvid-cloud"
}
EOF
}

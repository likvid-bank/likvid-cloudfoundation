include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}

inputs = {
  ci_service_account_email = dependency.bootstrap.outputs.ci_service_account_email
  hub                      = include.hub.locals
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  workspace = "devops-platform"
}

provider "stackit" {
  experiments = ["iam"]
}
EOF
}
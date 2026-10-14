include "common" {
  path = find_in_parent_folders("common.hcl")
}

# The backplane assigns `iaas.admin` on the organization, which only the organization-scoped account
# can do. Its key STACKIT_ORG_SERVICE_ACCOUNT_KEY lives only in Vault and not as a GitHub secret —
# skip from CI; run manually after sourcing setup-env.sh
exclude {
  if      = true
  actions = ["plan", "test"]
}

include "platform" {
  path = find_in_parent_folders("platform.hcl")
}

# Hub coordinates live in hub.hcl (single source of truth, shared with a future e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
}

dependency "landingzone" {
  config_path = "../../landingzone"
}

inputs = {
  hub                         = include.hub.locals
  stackit_project_id          = dependency.landingzone.outputs.foundation_project_id
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

provider "stackit" {
  service_account_key = var.stackit_service_account_key
  experiments         = ["iam"]
}
EOF
}

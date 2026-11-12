include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Also carries this platform's remote_state, so the unit's state prefix matches its siblings.
include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# Hub coordinates live in hub.hcl (single source of truth, shared with e2e/).
include "hub" {
  path   = "./hub.hcl"
  expose = true
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

provider "google" {
  region = "europe-west3"
}
EOF
}

inputs = {
  hub = {
    git_ref   = include.hub.locals.git_ref
    bbd_draft = include.hub.locals.bbd_draft
  }

  backplane_project_id = include.platform.locals.platform.gcp.project
  billing_account_id   = include.platform.locals.platform.gcp.billingAccount

  # The platform team's workspace, which owns every building block definition this foundation
  # publishes. The backplane federates only this workspace's building block runners.
  owning_workspace_identifier = "devops-platform"

  smoke_test_tenant = {
    workspace          = "cloudf-oundation"
    platform_tenant_id = "cloud-foundatio-buildingbl-8yv"
  }
}

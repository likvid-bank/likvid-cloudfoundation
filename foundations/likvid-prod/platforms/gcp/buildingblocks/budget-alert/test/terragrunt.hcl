include "common" {
  path = find_in_parent_folders("common.hcl")
}

# this module only supports the test command!
exclude {
  if      = true
  actions = ["plan", "apply", "destroy"]
}

# this is a test for a meshStack building block
dependency "backplane" {
  config_path = "../backplane"
}

inputs = {
  project_id           = "cloud-foundatio-buildingbl-8yv" # workspace cloudf-oundation, project buildingblocks-testing
  billing_account_id   = dependency.backplane.outputs.billing_account_id
  backplane_project_id = dependency.backplane.outputs.backplane_project_id
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/gcp/budget-alert/buildingblock?ref=6d62a242a59dca350894e3834d7b439ac6802b87"

  extra_arguments "env" {
    commands  = ["test", "plan", "apply"]
    arguments = []
    env_vars = {
      GOOGLE_CREDENTIALS = dependency.backplane.outputs.credentials_json
    }
  }
}

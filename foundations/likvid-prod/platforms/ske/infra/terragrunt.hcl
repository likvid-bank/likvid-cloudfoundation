include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "ske" {
  path = find_in_parent_folders("ske.hcl")
}

dependency "project" {
  config_path = "../tenant"
  mock_outputs = {
    stackit_project_id = "00000000-0000-0000-0000-000000000000"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  default_region        = "eu01"
  service_account_key   = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF
}

inputs = {
  stackit_project_id = dependency.project.outputs.stackit_project_id
}

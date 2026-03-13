include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "tfstate" {
  path = find_in_parent_folders("tfstate.hcl")
}

dependency "meshstack" {
  config_path = "../meshstack"
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
  enable_beta_resources = true # required for stackit_git resource
}
EOF
}

inputs = {
  stackit_project_id = dependency.meshstack.outputs.stackit_project_id
  # TODO: This is a workaround that we need to create a PAT for the created STACKIT git instance
  forgejo_token = get_env("STACKIT_GIT_FORGEJO_TOKEN")
}

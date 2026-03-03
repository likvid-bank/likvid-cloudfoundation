include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "idp" {
  path = find_in_parent_folders("idp.hcl")
}

dependency "project" {
  config_path = "../tenant"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "stackit" {
  default_region      = "eu01"
  service_account_key = ${jsonencode(get_env("STACKIT_SKE_PROJECT_SERVICE_ACCOUNT_KEY"))}
}
EOF
}

inputs = {
  stackit_project_id = dependency.project.outputs.stackit_project_id
}

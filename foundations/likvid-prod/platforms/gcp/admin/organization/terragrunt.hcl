include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  region      = "europe-west3"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/admin/organization"
}

inputs = {
  # todo: set input variables
  foundation                  = "string"
  foundation_project_id       = "string"
  parent_folder_id            = "string"
  domains_to_allow            = []
  customer_ids_to_allow       = []
  resource_locations_to_allow = []
}
include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
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
  foundation            = "likvid-prod"
  foundation_project_id = include.platform.locals.platform.gcp.project
  parent_folder_id      = dependency.bootstrap.outputs.parent_folder_id
  domains_to_allow      = ["dev.meshcloud.io"]
  customer_ids_to_allow = [
    # we don't have access to the meshcloud.io Org with our foundation principal, we hence have to specifiy this explicitly
    {
      domain      = "meshcloud.io"
      customer_id = "C028009kx"
    }
  ]
  resource_locations_to_allow = ["in:eu-locations"]
}
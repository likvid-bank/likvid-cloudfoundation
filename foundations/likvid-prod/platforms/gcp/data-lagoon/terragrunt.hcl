include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    project  = "data-lagoon-prod-45o"
    location = "eu"
    bucket   = "likvid-data-lagoon-bb-tf-backend"
    prefix   = "terraform/data-lagoon/terraform.tfstate"
  }
}

# todo: setup providers as needed by your kit module, typically referencing outputs of the bootstrap module
# note: this block is generated as a fallback, since the kit module provided no explicit terragrunt.hcl template
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# todo: add provider {} blocks as needed
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/data-lagoon"
}

inputs = {
  project_id       = "data-lagoon-prod-45o"
  parent_folder_id = "folders/493343334220" # TODO read from organizational hierarchy kit module output
}

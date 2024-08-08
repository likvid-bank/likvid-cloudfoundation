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
    prefix   = "terraform/buildingblock-backplane/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# todo: add provider {} blocks as needed
EOF
}

terraform {
  source = "${get_repo_root()}//kit/gcp/buildingblocks/automation"
}

inputs = {

}

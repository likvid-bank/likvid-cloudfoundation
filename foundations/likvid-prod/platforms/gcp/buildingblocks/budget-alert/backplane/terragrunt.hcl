include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization" {
  config_path = "../../../admin/organization"
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/gcp/budget-alert/backplane?ref=6d62a242a59dca350894e3834d7b439ac6802b87"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  region      = "europe-west3"
}
EOF
}

inputs = {
  backplane_project_id = include.platform.locals.platform.gcp.project
  billing_account_id   = include.platform.locals.platform.gcp.billingAccount
}

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

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  access_key = "${dependency.backplane.outputs.credentials.AWS_ACCESS_KEY_ID}"
  secret_key = "${dependency.backplane.outputs.credentials.AWS_SECRET_ACCESS_KEY}"
  region     = "eu-central-1"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/s3_bucket/buildingblock?ref=dae10261fe831dcc00a3a9a4fc6b3b00d9018da3"
}

inputs = {
  # defined in the test
}

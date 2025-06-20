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
  source = "https://github.com/meshcloud/collie-hub.git//kit/aws/buildingblocks/s3_bucket/buildingblock?ref=v0.5.5"
}

inputs = {
  bucket_name = "s3-bucket-bb-terragrunt-test-likvid" # used for testing
}

# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../backplane"
}

inputs = {
  account_id       = "934977584221" # owned by workspace cloud-foundation project buildingblocks-testing
  assume_role_name = dependency.buildingblock.outputs.role_name
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aws/budget-alert/buildingblock?ref=e71a223f981884536aaeb2f4ef081d08bb4623ba"

  extra_arguments "env" {
    commands  = ["test", "plan", "apply"]
    arguments = []
    env_vars = {
      # Unset any AWS credentials that might be set by CI environment
      AWS_PROFILE        = ""
      AWS_SESSION_TOKEN  = ""
      AWS_DEFAULT_REGION = ""

      AWS_REGION            = "eu-central-1"
      AWS_ACCESS_KEY_ID     = dependency.buildingblock.outputs.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = dependency.buildingblock.outputs.aws_secret_access_key
    }
  }
}

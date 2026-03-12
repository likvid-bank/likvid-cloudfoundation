locals {
  cloudfoundation = "likvid"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "likvid-tf-state"
    # note: we put in a platforms/stackit prefix into the bucket key because we also put state for foundation modules
    # into this same bucket
    key            = "platforms/stackit/${path_relative_to_include()}.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::490004649140:role/OrganizationAccountAccessRole"

    profile = get_env("CI", "false") == "true" ? null : local.cloudfoundation
  }
}

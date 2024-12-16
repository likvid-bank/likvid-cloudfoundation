locals {
  # make platform config available
  platform = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket = "likvid-tf-state"
    # note: we put in a platforms/aws prefix into the bucket key because we also put state for foundation modules
    # into this same bucket
    key            = "platforms/sapbtp/${path_relative_to_include()}.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::490004649140:role/OrganizationAccountAccessRole"

    profile = get_env("CI", "false") == "true" ? null : local.cloudfoundation
  }
}

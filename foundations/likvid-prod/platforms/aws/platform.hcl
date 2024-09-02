locals {
  // todo: refactor this into a foundation.hcl
  cloudfoundation = "likvid"

  // make platform config available
  platform = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])

  #foundation_pam = read_terragrunt_config(find_in_parent_folders("pam.hcl")).locals

  roles = {
    deployment = "OrganizationAccountAccessRole"
    validation = "${local.cloudfoundation}-AuditorRole"
  }

  # we have to manually switch the role to be assumed in CI because we cannot override this with an env var
  # see https://github.com/hashicorp/terraform-provider-aws/issues/32617#issuecomment-2062072613
  active_role = get_env("CI", "false") == "true" ? local.roles.validation : local.roles.deployment

  # Useful override for locally testing with readonly permissions like in CI, DO NOT COMMIT/MERGE THIS
  # active_role = local.roles.validation
}

terraform {
  # always activate the right AWS CLI profile before running the bootstrap
  extra_arguments "profile" {
    commands = [
      "init",
      "apply",
      "plan",
      "import",
      "state"
    ]

    env_vars = get_env("CI", "false") == "true" ? {} : {
      # activate a local CLI profile when not in CI
      AWS_PROFILE = local.cloudfoundation
    }
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "likvid-tf-state"
    key            = "platforms/aws/${local.cloudfoundation}.${path_relative_to_include()}"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::490004649140:role/OrganizationAccountAccessRole"
  }
}


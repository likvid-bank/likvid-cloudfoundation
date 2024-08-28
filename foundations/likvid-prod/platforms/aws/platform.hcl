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

# In this first iteration of the redesign of the Likvid AWS Platform, we have decided to use the same bucket as for meshcloud-dev.
# This can be a temporary solution and may be changed in the future. It depends on an LZA in AWS and the resulting kitso
# that we will be writing for this.

remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket               = "foundation-meshcloud-dev-tf-states"
    prefix               = "platforms/aws/${local.cloudfoundation}.${path_relative_to_include()}"
    skip_bucket_creation = true
  }
}

locals {
  # define shared configuration here that's included by all terragrunt configurations in this locals
  platform        = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])
  cloudfoundation = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../..//README.md"))[0])
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    profile        = local.platform.cli.aws.AWS_PROFILE
    region         = local.platform.cli.aws.AWS_REGION
    bucket         = "cloud-foundation-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    encrypt       = true
    dynamodb_table = "cloud-foundation-terraform-state-lock-table"
    allowed_account_ids = [local.platform.aws.accountId]
  }
}

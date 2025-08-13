data "github_repository" "static_website_assets" {
  name = var.repository
}

resource "github_actions_secret" "static_website_assets_api_key_secret" {
  repository      = data.github_repository.static_website_assets.name
  secret_name     = "BUILDINGBLOCK_API_KEY_SECRET"
  plaintext_value = var.meshstack_api_key_secret
}

resource "github_actions_variable" "static_website_assets_api_key_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "BUILDINGBLOCK_API_CLIENT_ID"
  value         = var.meshstack_api_key_id
}

resource "github_actions_variable" "static_website_assets_aws_sso_instance_arn" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "SSO_INSTANCE_ARN"
  value         = var.aws_sso_instance_arn
}

resource "github_actions_variable" "static_website_assets_aws_identity_store_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "IDENTITY_STORE_ID"
  value         = var.aws_identity_store_id
}

resource "github_actions_variable" "static_website_assets_aws_account_id" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "AWS_ACCOUNT_ID"
  value         = var.aws_account_id
}

resource "github_actions_variable" "static_website_assets_aws_role_to_assume" {
  repository    = data.github_repository.static_website_assets.name
  variable_name = "AWS_ROLE_TO_ASSUME"
  value         = var.gha_aws_role_to_assume
}

locals {
  # fileset ignores dotfiles by default so we use a workaround
  github_files = fileset("${path.module}/dotgithub", "**/*.yml")
}

resource "github_repository_file" "static_website_assets_workflow_files" {
  for_each            = { for file in local.github_files : file => file }
  repository          = data.github_repository.static_website_assets.name
  file                = ".github/${each.key}"
  content             = file("${path.module}/dotgithub/${each.key}")
  overwrite_on_create = true
}
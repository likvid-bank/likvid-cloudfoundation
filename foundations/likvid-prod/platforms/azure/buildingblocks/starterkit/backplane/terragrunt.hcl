include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# note: the subscription hosting the buildingblock backplane is managed via meshStack in
#   Workspace: DevOps Toolchain
#   Project: buildingblocks-prod
# azurerm therefore uses local Azure CLI user authentication

# todo: not quite sure how this will interact with our ability to generate docs in CI/CD for this module
# it _should_ be fine since we only need to read terraform statex^^

dependency "sandbox" {
  config_path = "../../../landingzones/sandbox"
}

# For GitHub we use github cli authentication see https://registry.terraform.io/providers/integrations/github/latest/docs#github-cli
# Unless we run in CI, where we need to use app authentication. For convenience we reuse the same app we use for
# automating BB deploys.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "github" {
  owner = "likvid-bank"

  %{if try(get_env("CI"), null) != null}
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    # pem_file sourced from env var GITHUB_APP_PEM_FILE
  }
  %{endif}
}

provider "azuread" {
  tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true # work around a missing permission in Azure
  storage_use_azuread        = true

  # this subscription is managed via meshStack, we hence do not track it as a tenant in this repo
  subscription_id = "76a68a1d-674b-401b-976a-8b251d535f8c"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/starterkit/backplane?ref=v0.5.3"
}

inputs = {
  service_principal_name = "devops-toolchain-starterkit"
  location               = "germanywestcentral"
  scope                  = dependency.sandbox.outputs.sandbox_id

  github_app_id              = "654209"
  github_app_installation_id = "44437049"
  github_org                 = "likvid-bank"
}

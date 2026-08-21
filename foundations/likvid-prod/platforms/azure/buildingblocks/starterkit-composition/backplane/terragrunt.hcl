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

dependency "automation" {
  config_path = "../../automation"
}

# No `provider "github"` block: the hub module declares the github provider in `versions.tf` but has no
# github resource or data source, so there is nothing to configure. The block this unit used to generate
# also referenced `var.github_app_id` and `var.github_app_installation_id`, which the module does not
# declare — it takes only `application_name`, `location` and `scope`. That never failed, because an unused
# provider block is not evaluated, so the undeclared references stayed invisible to both validate and plan.
# ICF's equivalent unit dropped the block in `6528674d`.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azuread" {
  tenant_id             = "${dependency.automation.outputs.tenant_id}"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true # work around a missing permission in Azure
  storage_use_azuread        = true

  # this subscription is managed via meshStack, we hence do not track it as a tenant in this repo
  subscription_id       = "${dependency.automation.outputs.subscription_id}"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/azure/github-actions-terraform-setup/backplane?ref=c65ffbfcdfed3f6db503eb99004fce469bd70abe"
}

inputs = {
  application_name = "devops-toolchain-starterkit-composition"
  location         = "germanywestcentral"
  scope            = dependency.sandbox.outputs.sandbox_id
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

# this module only supports the test command!
exclude {
  if      = true
  actions = ["plan", "apply", "destroy"]
}

# this is a test for a meshStack building block
# hence it's using config.tf, and not collie-style composition (maybe we should align the two and let collie use config_tf style as well)
dependency "buildingblock" {
  config_path = "../backplane"
}

dependency "automation" {
  config_path = "../../automation"
}

# generate a config.tf file for automating building block deployments via meshStack
generate "config" {
  path      = "config.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    subscription_id       = "${dependency.automation.outputs.subscription_id}"
    resource_group_name   = "${dependency.automation.outputs.resource_group_name}"
    storage_account_name  = "${dependency.automation.outputs.storage_account_name}"
    container_name        = "${dependency.automation.outputs.container_name}"
    key                   = "custom-permissions.tfstate"

    client_id             = "${dependency.automation.outputs.client_id}"
    client_secret         = "${dependency.automation.outputs.client_secret}"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = false

  tenant_id       = "${dependency.automation.outputs.tenant_id}"

  # this var will be injected by the buildingblock runner
  subscription_id = var.subscription_id

  client_id             = "${dependency.automation.outputs.client_id}"
  client_secret         = "${dependency.automation.outputs.client_secret}"
}

provider "azuread" {
  tenant_id       = "${dependency.automation.outputs.tenant_id}"

  client_id       = "${dependency.automation.outputs.client_id}"
  client_secret   = "${dependency.automation.outputs.client_secret}"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/custom-permissions/buildingblock?ref=v0.5.3"
}

inputs = {
  # https://portal.azure.com/#@devmeshcloud.onmicrosoft.com/resource/subscriptions/a7d09781-d7a9-4e0b-a93c-c9e95d079a13/users
  subscription_id      = "717b13ac-2baa-4899-b90c-c91723f23c21"
  workspace_identifier = "likvid-mobile"
  project_identifier   = "develop"
  users                = []
}

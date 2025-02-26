dependency "automation" {
  config_path = "../../../../azure/buildingblocks/automation"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "azurerm" {
  features {}

  storage_use_azuread        = true

  # this subscription is managed via meshStack, we hence do not track it as a tenant in this repo
  subscription_id       = "7490f509-073d-42cd-a720-a7f599a3fd0b"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/collie-hub.git//kit/aks/buildingblocks/github-connector/backplane?ref=v0.5.3"
}

inputs = {
  tfstates_resource_manager_id    = dependency.automation.outputs.resource_manager_id
  tfstates_resource_group_name    = dependency.automation.outputs.resource_group_name
  tfstates_storage_account_name   = dependency.automation.outputs.storage_account_name
  tfstates_storage_container_name = dependency.automation.outputs.container_name
}

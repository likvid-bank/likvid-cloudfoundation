output "config_tf" {
  description = "Generates a config.tf that can be dropped into meshStack's BuildingBlockDefinition as an encrypted file input to configure this building block."
  sensitive   = true
  value       = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${data.azurerm_subscription.current.tenant_id}"
    subscription_id       = "${data.azurerm_subscription.current.id}"
    resource_group_name   = "${azurerm_resource_group.tfstates.name}"
    storage_account_name  = "${azurerm_storage_account.tfstates.name}"
    container_name        = "${azurerm_storage_container.tfstates.name}"
    key                   = "buildingblocks.tfstate"
  }
}

provider "github" {
  app_auth {
    id              = "${local.github_app_id}"
    installation_id = "${local.github_app_installation_id}"
    
    # TODO: ensure the pem file exists on disk in the BB execution environment (with meshStack: secret file input)
    pem_file = file("./likvid-bank-devops-toolchain-team.private-key.pem").
  }
}
EOF
}
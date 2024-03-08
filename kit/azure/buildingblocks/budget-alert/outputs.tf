output "config_tf" {
  description = "Generates a config.tf that can be dropped into meshStack's BuildingBlockDefinition as an encrypted file input to configure this building block."
  sensitive   = true
  value       = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${data.azurerm_subscription.current.tenant_id}"
    subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
    resource_group_name   = "${azurerm_resource_group.tfstates.name}"
    storage_account_name  = "${azurerm_storage_account.tfstates.name}"
    container_name        = "${azurerm_storage_container.tfstates.name}"
    key                   = "${var.name}.tfstate"

    client_id             = "${azuread_service_principal.buildingblock.client_id}"
    client_secret         = "${azuread_service_principal_password.buildingblock.value}"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  storage_use_azuread        = true

  tenant_id       = "${data.azurerm_subscription.current.tenant_id}"
  subscription_id = var.subscription_id # this will be injected by the buildingblock runner
  client_id       = "${azuread_service_principal.buildingblock.client_id}"
  client_secret   = "${azuread_service_principal_password.buildingblock.value}"
}

locals {
  deploy_role_definition_id = "${azurerm_role_definition.buildingblock_deploy.role_definition_resource_id}"
}
EOF
}

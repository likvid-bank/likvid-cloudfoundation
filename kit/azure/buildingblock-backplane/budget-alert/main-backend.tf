variable "storage_account_resource_id" {
  type        = string
  description = "This is the ID of the storage account resource and it retrievable via panel. It is in the format of '/subscription/<sub_id>/resourcegroups/<rg_name>/..."
}

variable "tenant_id" {
  type        = string
  description = "Tenant id of the storage account"
}

variable "sta_subscription_id" {
  type        = string
  description = "Id of the subscription holding the backend's storage account"
}

variable "sta_rg_name" {
  type        = string
  description = "Resource group name holding the storage account"
}

variable "sta_name" {
  type        = string
  description = "Storage account name"
}

variable "backend_tf_config_path" {
  type = string
}

variable "container_name" {
  type        = string
  description = "Container name holding the tfstates"
}

variable "generate_local_files" {
  type        = number
  description = "Please Enter '1' in order to generate the outputs as file. Default is '0'"
  default     = "0"
}

output "backend_tf" {
  sensitive   = true
  description = "Generates a config.tf that can be dropped into meshStack's BuildingBlock Definition as an encrypted file input to configure this building block."
  value       = <<EOF
terraform {
  backend "azurerm" {
    tenant_id            = "${var.tenant_id}"
    subscription_id      = "${var.sta_subscription_id}"
    client_id            = "${azuread_application.building_blocks.client_id}"
    client_secret        = "${azuread_application_password.building_blocks_application_pw.value}"
    resource_group_name  = "${var.sta_rg_name}"
    storage_account_name = "${var.sta_name}"
    container_name       = "${var.container_name}"
    key                  = "buildingblock-budget-alert"
  }
}
EOF
}


resource "local_file" "backend" {
  count    = var.generate_local_files
  filename = var.backend_tf_config_path
  content  = <<-EOT
terraform {
  backend "azurerm" {
    tenant_id            = "${var.tenant_id}"
    subscription_id      = "${var.sta_subscription_id}"
    client_id            = "${azuread_application.building_blocks.client_id}"
    client_secret        = "${azuread_application_password.building_blocks_application_pw.value}"
    resource_group_name  = "${var.sta_rg_name}"
    storage_account_name = "${var.sta_name}"
    container_name       = "${var.container_name}"
    key                  = "buildingblock-budget-alert"
  }
}
EOT
}


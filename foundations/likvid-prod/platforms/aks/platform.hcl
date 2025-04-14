locals {
  # make platform config available
  platform        = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])
  platform_azure  = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("..////azure/README.md"))[0])
  cloudfoundation = "likvid-prod"

  # if we use terraform_state_storage, it will generate this file here to provide backend configuration
  terraform_state_config_file_path = "..////azure/tfstates-config.yml"
  tfstateconfig                    = try(yamldecode(file(local.terraform_state_config_file_path)), null)
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    use_azuread_auth      = true
    tenant_id             = "${local.platform_azure.azure.aadTenantId}"
    subscription_id       = "${local.platform_azure.azure.subscriptionId}"
    resource_group_name   = "${local.tfstateconfig.resource_group_name}"
    storage_account_name  = "${local.tfstateconfig.storage_account_name}"
    container_name        = "${local.tfstateconfig.container_name}"
    key                   = "platforms/aks/${path_relative_to_include()}.tfstate"
  }
}
EOF
}

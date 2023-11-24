locals {
  # define shared configuration here that's included by all terragrunt configurations in this locals
  platform        = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file(".//README.md"))[0])
  cloudfoundation = yamldecode(regex("^---([\\s\\S]*)\\n---\\n[\\s\\S]*$", file("../..//README.md"))[0])

  # if we use terraform_state_storage, it will generate this file here to provide backend configuration
  terraform_state_config_file_path = "${get_parent_terragrunt_dir()}/tfstates-config.yml"
  tfstateconfig                    = try(yamldecode(file(local.terraform_state_config_file_path)), null)
}

# terragrunt does not support azure remote_state, so we use a traditional generate block

# see https://developer.hashicorp.com/terraform/language/settings/backends/azurerm for config options
# ACTIONS_ID_TOKEN_REQUEST_URL is set by GitHub actions runtime
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  %{if local.tfstateconfig != null}
  backend "azurerm" {
    %{if try(get_env("ACTIONS_ID_TOKEN_REQUEST_URL"), null) != null}
    use_oidc              = true
    client_id             = "11a89d3c-4fe7-4d94-bcee-c257f7a33009"
    %{endif}
    use_azuread_auth      = true
    tenant_id             = "${local.platform.azure.aadTenantId}"
    subscription_id       = "${local.platform.azure.subscriptionId}"
    resource_group_name   = "${try(local.tfstateconfig.resource_group_name, "")}"
    storage_account_name  = "${try(local.tfstateconfig.storage_account_name, "")}"
    container_name        = "${try(local.tfstateconfig.container_name, "")}"
    key                   = "${path_relative_to_include()}.tfstate"
  }
  %{else}
  backend "local" {
  }
  %{endif}
}
EOF
}

terraform {
  before_hook "collie_info" {
    commands     = ["apply", "plan", "output"]
    execute      = ["echo", "--- BEGIN COLLIE PLATFORM MODULE OUTPUT: ${path_relative_to_include()} ---"]
  }
}
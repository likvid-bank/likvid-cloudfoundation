include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "${path_relative_from_include()}/bootstrap"
}

dependency "storage_account" {
  config_path = "${path_relative_from_include()}/buildingblock-backplane/storage-account"
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblock-backplane/monitoring/budget-alert"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "0688c9ba-193b-49f3-a3a5-98735a3908df"
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"
}

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  client_id       = "${dependency.bootstrap.outputs.client_id}"
  client_secret   = "${dependency.bootstrap.outputs.client_secret}"
}
EOF
}

inputs = {
  # todo: set input variables
  storage_account_resource_id = "${dependency.storage_account.outputs.storage_account_id}"
  container_id                = "${dependency.storage_account.outputs.container_id}"
  tenant_id                   = "${include.platform.locals.platform.azure.aadTenantId}"
  sta_subscription_id         = "${include.platform.locals.platform.azure.subscriptionId}"
  sta_rg_name                 = "${dependency.storage_account.outputs.resource_group_name}"
  sta_name                    = "${dependency.storage_account.outputs.storage_account_name}"
  container_name              = "${dependency.storage_account.outputs.container_name}"
  sta_rg_id                   = "${dependency.storage_account.outputs.resource_group_id}"

  #"The scope where this service principal have access on. Usually in the format of '/providers/Microsoft.Management/managementGroups/0000-0000-0000'"
  deployment_scope        = "/providers/Microsoft.Management/managementGroups/XXXXXXX"
  backend_tf_config_path  = "${get_repo_root()}/foundations/likvid-prod/platforms/azure/buildingblock-backplane/budget-alert/outputs/generated-backend.tf"
  provider_tf_config_path = "${get_repo_root()}/foundations/likvid-prod/platforms/azure/buildingblock-backplane/budget-alert/outputs/generated-provider.tf"
  generate_local_files    = "0" # Change it to '1' in order to have the outputs as file.
}

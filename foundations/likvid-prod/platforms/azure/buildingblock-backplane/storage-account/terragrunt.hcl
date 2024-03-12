include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/buildingblock-backplane/storage-account"
}

dependency "bootstrap" {
  config_path = "../../bootstrap"
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = true
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform.azure.subscriptionId}"
}

EOF
}


inputs = {
  # todo: set input variables
  subscription_id          = "${include.platform.locals.platform.azure.subscriptionId}"
  storage_account_name     = "meshclouddemobackendbb"
  resource_group_name      = "rg-likvid-bb-backend"
  location                 = "germanywestcentral"
  account_replication_type = "ZRS"
  containers = [
    {
      name        = "bbtfstates"
      access_type = "private"
    }
  ]

}

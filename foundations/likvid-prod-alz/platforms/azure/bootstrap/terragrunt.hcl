include "platform" {
    path = find_in_parent_folders("platform.hcl")
    expose = true
  }

# todo: this is a bootstrap module, you typically want to set up a provider
  # with user credentials (cloud CLI based authentication) here
  generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  skip_provider_registration = false
  tenant_id                  = "${include.platform.locals.platform.azure.aadTenantId}"
  subscription_id            = "${include.platform.locals.platform.azure.subscriptionId}"
  storage_use_azuread        = true
}
provider "azuread" {
  tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
}
EOF
}

terraform {
    source = "${get_repo_root()}//kit/alz/bootstrap"
  }

inputs = {
    root_parent_id = "${include.platform.locals.platform.azure.aadTenantId}"
    foundation_name = "likvid-prod-alz"
    platform_engineers_members = [
      "XXXX#EXT#@dXXXXX.onmicrosoft.com",
    ]
    storage_account_name = "tfstates4565"
    storage_rg_name = "alz-tfstates4565"
    tfstate_location     = "germanywestcentral"

  }

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
}

provider "azuread" {
  tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
}
EOF
}

terraform {
  source = "${get_repo_root()}//kit/azure/bootstrap"
}

inputs = {
  location = "Germany West Central"
}
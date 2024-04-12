include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

# this is a bootstrap module, so we set up a provider
# with user credentials (az CLI based authentication) here
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


locals {
  platform_engineers_emails = [
    "jrudolph@meshcloud.io",
    "fnowarre@meshcloud.io",
    "pmoore@meshcloud.io",
    "jdburger@meshcloud.io",
    "mkazemi@meshcloud.io",
    "malhussan@meshcloud.io",
    "fzieger@meshcloud.io",
    "hdettmer@meshcloud.io",
  ]

  # Likvid Bank's AAD used in this demo is a "workload AAD tenant" that doesn't have its own users,
  # so we need to invite all users via AAD B2B
  platform_engineers_members = [
    for x in local.platform_engineers_emails : {
      email = x
      upn   = "${replace(x, "@", "_")}#EXT#@devmeshcloud.onmicrosoft.com"
    }
  ]
}

terraform {
  source = "${get_repo_root()}//kit/azure/bootstrap"

  # Technically we could assume the right subscription is set via the provider.tf config already, but it seems that's
  # not sufficient, we still see authentication errors (and long timeouts) unless the right subscription is configured
  # explicitly before running terraform - so we just do that to be sure.
  # This will only affect the az cli configuration stored in $AZURE_CONFIG_DIR
  before_hook "az_account_set" {
    commands = ["apply", "plan"]
    execute  = ["az", "account", "set", "--subscription", "${include.platform.locals.platform.azure.subscriptionId}"]
  }
}

inputs = {
  aad_tenant_id                = include.platform.locals.platform.azure.aadTenantId
  parent_management_group_name = "likvid-foundation"

  platform_engineers_members = local.platform_engineers_members
  platform_engineers_group   = "likvid-cloudfoundation-platform-engineers"

  documentation_uami = {
    name         = "likvid_foundation_tf_docs_user"
    oidc_subject = "repo:likvid-bank/likvid-cloudfoundation:environment:github-pages"
  }

  validation_uami = {
    name         = "likvid_foundation_tf_validation_user"
    oidc_subject = "repo:likvid-bank/likvid-cloudfoundation:environment:likvid-prod"
  }

  key_vault = {
    name                = "likvid-cloudfoundation-kv"
    resource_group_name = "likvid-cloudfoundation-keyvault"
  }

  terraform_state_storage = {
    name                = "${include.platform.locals.cloudfoundation.name}"
    location            = "germanywestcentral"                                     #TODO change, the azure location of the resource group and storage account
    config_file_path    = include.platform.locals.terraform_state_config_file_path # platform.hcl expects state configuration output in this location, do not change
    resource_group_name = "cloudfoundation-tfstates"
  }

}

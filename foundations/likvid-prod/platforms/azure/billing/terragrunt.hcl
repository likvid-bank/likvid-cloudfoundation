include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}//kit/azure/billing"
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "organization-hierarchy" {
  config_path = "../organization-hierarchy"
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

provider "azuread" {
  tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
}
EOF
}


inputs = {
  # todo: set input variables
  scope = "${dependency.organization-hierarchy.outputs.parent_id}"
  budget_time_period = [{
    start = "2023-11-01T00:00:00Z"
  }]
  contact_mails = ["jrudolph@meshcloud.io"]

  billing_admin_group  = "likvid-cloudfoundation-billing-admins"
  billing_reader_group = "likvid-cloudfoundation-billing-readers"
}

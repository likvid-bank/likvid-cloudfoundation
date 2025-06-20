include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "bootstrap" {
  config_path = "../bootstrap"
}

dependency "logging" {
  config_path = "../logging"
}

dependency "billing" {
  config_path = "../billing"
}

dependency "networking" {
  config_path = "../networking"
}

terraform {
  source = "${get_repo_root()}//kit/azure/pam"
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
  pam_group_object_ids = [
    dependency.bootstrap.outputs.platform_engineers_azuread_group_id,
    dependency.billing.outputs.billing_admins_azuread_group_id,
    dependency.billing.outputs.billing_readers_azuread_group_id,
    dependency.logging.outputs.security_admins_azuread_group_id,
    dependency.logging.outputs.security_auditors_azuread_group_id,
    dependency.networking.outputs.network_admins_azuread_group_id,
  ]

  # optional, manage members direcly via terraform
  pam_group_members = [
    {
      group_object_id = dependency.billing.outputs.billing_admins_azuread_group_id,
      members_by_mail = ["jrudolph@meshcloud.io", "ckraus@meshcloud.io"]
    },
    {
      group_object_id = dependency.logging.outputs.security_admins_azuread_group_id,
      members_by_mail = ["jrudolph@meshcloud.io", "ckraus@meshcloud.io", "fnowarre@meshcloud.io"]
    },
    {
      group_object_id = dependency.networking.outputs.network_admins_azuread_group_id,
      members_by_mail = ["jrudolph@meshcloud.io", "fnowarre@meshcloud.io"]
    }
    # note: platform_engineers members are managed via bootstrap module right now
  ]
}


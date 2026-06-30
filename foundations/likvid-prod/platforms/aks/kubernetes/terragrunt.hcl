include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "meshstack" {
  config_path = "../meshstack"
  mock_outputs = {
    subscription_id = "00000000-0000-0000-0000-000000000000"
  }
}

inputs = {
  subscription_id          = dependency.meshstack.outputs.subscription_id
  platform_engineers_group = include.platform.locals.platform_engineers_group
}

terraform {
  extra_arguments "azure_env" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      ARM_SUBSCRIPTION_ID = dependency.meshstack.outputs.subscription_id
    }
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "azurerm" {
    features {}
  }

  provider "azurerm" {
    alias    = "hub"
    features {}
  }

  provider "azuread" {
    tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
  }
  EOF
}

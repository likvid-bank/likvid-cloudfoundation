include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "organization_hierarchy" {
  config_path = "../organization-hierarchy"
  mock_outputs = {
    parent_id       = "/providers/Microsoft.Management/managementGroups/mock-parent"
    landingzones_id = "/providers/Microsoft.Management/managementGroups/mock-landingzones"
    platform_id     = "/providers/Microsoft.Management/managementGroups/mock-platform"
    connectivity_id = "/providers/Microsoft.Management/managementGroups/mock-connectivity"
    identity_id     = "/providers/Microsoft.Management/managementGroups/mock-identity"
    management_id   = "/providers/Microsoft.Management/managementGroups/mock-management"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "logging" {
  config_path = "../logging"
  mock_outputs = {
    law_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.OperationalInsights/workspaces/mock-law"
    logging_subscription = "/subscriptions/00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "sandbox" {
  config_path = "../landingzones/sandbox"
  mock_outputs = {
    sandbox_id = "/providers/Microsoft.Management/managementGroups/mock-sandbox"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = ".//."
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# No cloud provider needed — this module only renders local files.
EOF
}

inputs = {
  output_dir = get_terragrunt_dir()

  tenant_id = include.platform.locals.platform.azure.aadTenantId

  # organization-hierarchy
  parent_mg_id       = dependency.organization_hierarchy.outputs.parent_id
  landingzones_mg_id = dependency.organization_hierarchy.outputs.landingzones_id
  platform_mg_id     = dependency.organization_hierarchy.outputs.platform_id
  connectivity_mg_id = dependency.organization_hierarchy.outputs.connectivity_id
  identity_mg_id     = dependency.organization_hierarchy.outputs.identity_id
  management_mg_id   = dependency.organization_hierarchy.outputs.management_id

  # logging
  law_workspace_id        = dependency.logging.outputs.law_workspace_id
  logging_subscription_id = dependency.logging.outputs.logging_subscription
  log_retention_days      = 180

  # sandbox landing zone
  sandbox_mg_id = dependency.sandbox.outputs.sandbox_id
}

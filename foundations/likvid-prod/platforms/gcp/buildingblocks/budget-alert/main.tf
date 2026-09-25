module "budget_alert" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/gcp/budget-alert?ref=${var.hub.git_ref}"

  hub = var.hub

  meshstack = {
    owning_workspace_identifier = var.owning_workspace_identifier
  }

  gcp_backplane_project_id = var.backplane_project_id
  gcp_billing_account_id   = var.billing_account_id
}

# The smoke test's `target_ref` needs a meshTenant uuid, which only meshStack can supply. Resolving
# it here keeps every identifier in this repo human-readable. `one()` makes the unit fail loudly if
# the filter ever stops matching exactly one tenant, rather than silently exporting null.
data "meshstack_tenants" "smoke_test" {
  workspace          = var.smoke_test_tenant.workspace
  platform_tenant_id = var.smoke_test_tenant.platform_tenant_id
}

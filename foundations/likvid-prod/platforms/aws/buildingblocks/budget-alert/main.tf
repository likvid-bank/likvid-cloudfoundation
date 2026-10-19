module "budget_alert" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aws/budget-alert?ref=${var.hub.git_ref}"

  # The default provider applies against the automation account hosting the backplane;
  # `aws.management` against the organization's management account, which is the only place a
  # SERVICE_MANAGED StackSet can be created from.
  providers = {
    aws            = aws
    aws.management = aws.management
  }

  hub = var.hub

  meshstack = {
    owning_workspace_identifier = var.owning_workspace_identifier
  }

  aws_oidc_provider_arn        = var.oidc_provider_arn
  aws_target_ou_ids            = var.target_ou_ids
  aws_target_account_role_name = var.target_account_role_name
}

# The smoke test's `target_ref` needs a meshTenant uuid, which only meshStack can supply. Resolving
# it here keeps every identifier in this repo human-readable. `one()` makes the unit fail loudly if
# the filter ever stops matching exactly one tenant, rather than silently exporting null.
data "meshstack_tenants" "smoke_test" {
  workspace          = var.smoke_test_tenant.workspace
  platform_tenant_id = var.smoke_test_tenant.platform_tenant_id
}

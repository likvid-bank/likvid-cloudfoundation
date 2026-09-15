output "e2e" {
  value = {
    hub                       = var.hub
    building_block_definition = module.stackit_service_account_bb.building_block_definition
    owning_workspace          = local.meshstack.owning_workspace_identifier

    # Tenant-level fixtures for the e2e smoke test: `mesh_tenant_id` is the target_ref the ephemeral
    # service account is ordered into; `organization_id` / `project_id` back a build-from-source run.
    fixtures = {
      stackit = {
        organization_id = local.stackit_organization_id
        project_id      = meshstack_tenant.stackit_service_account.spec.platform_tenant_id
        mesh_tenant_id  = meshstack_tenant.stackit_service_account.metadata.uuid
      }
    }
  }
}

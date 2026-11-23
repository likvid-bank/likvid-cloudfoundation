# Consumed by the e2e/ sibling. It holds no secret: the smoke test looks the definition up through
# the meshStack API, so it needs the workspace that owns it, not its version ref.
output "e2e" {
  value = {
    owning_workspace = var.owning_workspace_identifier

    fixtures = {
      aws = {
        mesh_tenant_id = one(data.meshstack_tenants.smoke_test.tenants).metadata.uuid
      }
    }
  }
}

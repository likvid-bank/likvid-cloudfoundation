output "stackit_project_id" {
  description = "STACKIT project UUID provisioned by meshStack replication – consumed by kubernetes/"
  value       = meshstack_tenant_v4.this.spec.platform_tenant_id
}

moved {
  from = meshstack_tenant_v4.stackit
  to   = meshstack_tenant_v4.this
}

resource "meshstack_tenant_v4" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_identifier     = "stackit.sovereign"
    landing_zone_identifier = "stackit-prod"
  }
}

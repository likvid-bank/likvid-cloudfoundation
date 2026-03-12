output "stackit_project_id" {
  description = "STACKIT project UUID provisioned by meshStack replication – consumed by kubernetes/"
  value       = meshstack_tenant_v4.stackit.spec.platform_tenant_id
}

resource "meshstack_tenant_v4" "stackit" {
  metadata = {
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
    owned_by_project   = meshstack_project.stackit.metadata.name
  }

  spec = {
    platform_identifier     = "stackit.sovereign"
    landing_zone_identifier = "stackit-prod"
  }
}

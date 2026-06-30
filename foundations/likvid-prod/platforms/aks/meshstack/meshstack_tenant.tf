resource "meshstack_tenant_v4" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_identifier     = "azure.meshcloud-azure-dev"
    landing_zone_identifier = "likvid-azure-dev"
  }
}

output "subscription_id" {
  description = "Azure subscription ID provisioned by meshStack replication – consumed by kubernetes/ and meshstack/platform/"
  value       = meshstack_tenant_v4.this.spec.platform_tenant_id
}

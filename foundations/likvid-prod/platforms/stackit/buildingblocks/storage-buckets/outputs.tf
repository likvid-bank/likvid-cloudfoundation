output "e2e" {
  value = {
    hub                       = var.hub
    building_block_definition = module.stackit_storage_bucket_bb.building_block_definition
    owning_workspace          = local.meshstack.owning_workspace_identifier
  }
}

output "stackit_project_id" {
  value = meshstack_tenant.stackit_storage_buckets.spec.platform_tenant_id
}

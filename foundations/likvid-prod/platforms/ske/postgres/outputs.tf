output "instance_definition_ref" {
  value = data.meshstack_building_block_definition.instance.ref
}

output "connector_definition_ref" {
  value = meshstack_building_block_definition.connector.ref
}

output "instance_ids" {
  value = local.instance_ids
}

output "job_namespace" {
  value = meshstack_tenant.jobs.spec.platform_tenant_id
}

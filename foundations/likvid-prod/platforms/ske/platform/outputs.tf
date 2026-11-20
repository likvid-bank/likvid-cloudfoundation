output "owning_workspace" {
  value = local.owning_workspace_identifier
}

output "stackit_project_id" {
  description = "STACKIT project that holds the cluster and the platform's own building blocks."
  # The building block has no output for the bare ID.
  value = regex("project=([0-9a-f-]{36})", jsondecode(meshstack_building_block.platform.status.outputs["ske_project_url"].value))[0]
}

output "service_account_federation_bbd_version_ref" {
  description = "STACKIT Service Account Federation definition version the platform's federation building blocks run on."
  value       = { uuid = data.meshstack_building_block_definition.service_account_federation.version_latest_release.uuid }
}

output "e2e" {
  value = {
    hub                       = var.hub
    building_block_definition = module.stackit_storage_bucket_bb.building_block_definition
    owning_workspace          = local.meshstack.owning_workspace_identifier
  }
}

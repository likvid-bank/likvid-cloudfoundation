# Consumed by e2e/ to order an ephemeral building block against the deployed definition.
output "e2e" {
  value = {
    hub                       = var.hub
    building_block_definition = module.starterkit.building_block_definition
    owning_workspace          = var.meshstack.owning_workspace_identifier
  }
}

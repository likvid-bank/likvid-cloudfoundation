# Building block definitions owned by `stackit-platform` keep their backplane service accounts in the
# landing zone's foundation project, next to the ones the architecture registers itself.
output "foundation_project_id" {
  value = jsondecode(meshstack_building_block.this.status.outputs["foundation_project_id"].value)
}

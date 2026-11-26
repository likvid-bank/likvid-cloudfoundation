module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-landingzone-accelerator?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = "stackit-platform"
  }

  hub = var.hub
}

output "building_block_definition" {
  value = module.this.building_block_definition
}

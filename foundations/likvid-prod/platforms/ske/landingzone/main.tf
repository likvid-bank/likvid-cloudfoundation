module "this" {
  source = "github.com/meshcloud/meshstack-hub//reference-architectures/stackit-kubernetes?ref=${var.hub.git_ref}"

  meshstack = {
    owning_workspace_identifier = "stackit-ske-plat"
  }

  hub = {
    git_ref   = var.hub.git_ref
    bbd_draft = var.hub.bbd_draft
  }

  playground_mode = true
}

# Deployed by hand before this unit existed. ../platform manages the building block ordered from it.
import {
  to = module.this.meshstack_building_block_definition.this
  id = "ac8a784f-97ad-4670-bee4-7345776699a8"
}

output "building_block_definition" {
  value = module.this.building_block_definition
}

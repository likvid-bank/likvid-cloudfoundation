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

# Deployed by hand before this unit existed.
import {
  to = module.this.meshstack_building_block_definition.this
  id = "ac8a784f-97ad-4670-bee4-7345776699a8"
}

# Ordered by hand before this unit existed. Generate the resource block with
# `terragrunt plan -generate-config-out=generated.tf`, then move it here.
import {
  to = meshstack_building_block.this
  id = "429d067a-9e89-42d4-8180-e3827feafeae"
}

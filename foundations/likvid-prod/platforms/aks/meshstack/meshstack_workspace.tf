output "owning_workspace_identifier" {
  value = local.owning_workspace_identifier
}

locals {
  owning_workspace_identifier = data.meshstack_workspace.this.metadata.name
}

data "meshstack_workspace" "this" {
  metadata = {
    name = "devops-platform"
  }
}

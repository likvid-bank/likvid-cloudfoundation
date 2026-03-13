output "owning_workspace_identifier" {
  value = local.owning_workspace_identifier
}

locals {
  owning_workspace_identifier = data.meshstack_workspace.this.metadata.name
}

# Workspace is given to us, check for existence using datasource
data "meshstack_workspace" "this" {
  metadata = {
    name = "devops-platform"
  }
}

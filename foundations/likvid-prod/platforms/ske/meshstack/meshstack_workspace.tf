output "owning_workspace_identifier" {
  value = data.meshstack_workspace.devops_platform.metadata.name
}

data "meshstack_workspace" "devops_platform" {
  metadata = {
    name = "devops-platform"
  }
}

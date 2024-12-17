output "documentation_md" {
  value = <<EOF
# meshStack Integration

All of the service accounts and infrastructure required and directly owned by meshStack is contained in the
GCP Project with id `${google_project.meshstack_root.project_id}`.

> Note that meshStack has permissions to access infrastructure outside of this project. However, these assets
are owned by cloudfoundation, not meshStack.

For more details please refer to [meshStack docs](https://docs.meshcloud.io).

EOF
}

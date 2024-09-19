output "documentation_md" {
  value = <<EOF
# GitHub Building Block Automation Infrastructure

Infrastructure, for now, only includes a read-only deploy key (${github_repository_deploy_key.building_block_implementation.title})
to clone repo (${github_repository_deploy_key.building_block_implementation.repository}).

The private key needs to be uploaded into the building block definition "Private SSH Key". Fetch it through:

```bash
collie foundation deploy <foundation> --platform github --module buildingblocks/automation -- output ssh_private_key
```

EOF
}

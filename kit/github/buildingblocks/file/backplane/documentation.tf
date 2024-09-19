output "documentation_md" {
  value = <<EOF
# Backplane for GitHub File

GitHub App was set up manually. Integration with specific GitHub repos has to be requested from `jrudolph@meshcloud.io` or `hdettmer@meshcloud.io`.

Credentials are stored in Bitwarden and can be fetched by executing:

`collie foundation deploy <foundation> --platform github --module buildingblocks/file/backplane -- output -json`

which can then be used as static input in the building block definition.

EOF
}

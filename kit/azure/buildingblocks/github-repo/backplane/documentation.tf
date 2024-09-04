output "documentation_md" {
  value = <<EOF
# Github Repository

The Github Repository building block deploys a Github repository for the application team to store their code.

This building block is an essential part of the application infrastructure, enabling teams to focus on developing
their application without worrying about the underlying repository setup.

## Implementation Details

For automation purposes, we store the PEM file for authenticating to GitHub API in Azure Key Vault as ${data.azurerm_key_vault_secret.github_token.name}.
Right now, the secret needs to be manually set up and rotated.


EOF
}

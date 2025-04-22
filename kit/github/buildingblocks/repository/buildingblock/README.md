---
name: GitHub Repository Building Block
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# GitHub Repository Building Block

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.116.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 5.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_repository.repository](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | ID of the GitHub App | `string` | n/a | yes |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | Installation ID of the GitHub App | `string` | n/a | yes |
| <a name="input_github_app_pem_file"></a> [github\_app\_pem\_file](#input\_github\_app\_pem\_file) | GitHub App private key content | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Name of the GitHub organization | `string` | n/a | yes |
| <a name="input_repo_description"></a> [repo\_description](#input\_repo\_description) | Description of the GitHub repository | `string` | `"created by github-repo-building-block"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the GitHub repository | `string` | `"github-repo"` | no |
| <a name="input_repo_visibility"></a> [repo\_visibility](#input\_repo\_visibility) | Visibility of the GitHub repository | `string` | `"private"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_full_name"></a> [repo\_full\_name](#output\_repo\_full\_name) | n/a |
| <a name="output_repo_git_clone_url"></a> [repo\_git\_clone\_url](#output\_repo\_git\_clone\_url) | n/a |
| <a name="output_repo_html_url"></a> [repo\_html\_url](#output\_repo\_html\_url) | n/a |
| <a name="output_repo_name"></a> [repo\_name](#output\_repo\_name) | n/a |
<!-- END_TF_DOCS -->
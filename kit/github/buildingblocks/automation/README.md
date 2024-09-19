---
name: Building Blocks Automation Infrastructure
summary: |
  Creates a read-only deploy key for internal-cloudfoundation repo.
# optional: add additional metadata about implemented security controls
---

# Building Blocks Automation Infrastructure

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | 5.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_repository_deploy_key.building_block_implementation](https://registry.terraform.io/providers/integrations/github/5.42.0/docs/resources/repository_deploy_key) | resource |
| [tls_private_key.building_block_implementation](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation"></a> [foundation](#input\_foundation) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | n/a |
<!-- END_TF_DOCS -->
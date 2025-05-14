This building block is stateless (no backend) because it's to be used with purge deletion.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_meshstack"></a> [meshstack](#requirement\_meshstack) | >= 0.5.5 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.11.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [meshstack_building_block_v2.repo](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/building_block_v2) | resource |
| [meshstack_buildingblock.github_actions_dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/buildingblock) | resource |
| [meshstack_buildingblock.github_actions_prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/buildingblock) | resource |
| [meshstack_project.dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_tenant.dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [time_sleep.wait_2_minutes](https://registry.terraform.io/providers/hashicorp/time/0.11.1/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of of the resources and the repository to connect. | `string` | n/a | yes |
| <a name="input_workspace_identifier"></a> [workspace\_identifier](#input\_workspace\_identifier) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
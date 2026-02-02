This building block is stateless (no backend) because it's to be used with purge deletion.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_meshstack"></a> [meshstack](#requirement\_meshstack) | >= 0.8.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [meshstack_building_block_v2.github_actions_dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/building_block_v2) | resource |
| [meshstack_building_block_v2.github_actions_prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/building_block_v2) | resource |
| [meshstack_building_block_v2.repo](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/building_block_v2) | resource |
| [meshstack_project.dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project_user_binding.creator_dev_admin](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_project_user_binding.creator_prod_admin](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_tenant_v4.dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant_v4) | resource |
| [meshstack_tenant_v4.prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant_v4) | resource |
| [time_sleep.wait_45_seconds](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) | resource |
| [meshstack_building_block_v2.repo_data](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/data-sources/building_block_v2) | data source |
| [meshstack_tenant_v4.aks-dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/data-sources/tenant_v4) | data source |
| [meshstack_tenant_v4.aks-prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/data-sources/tenant_v4) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_creator"></a> [creator](#input\_creator) | Information about the creator of the resources who will be assigned Project Admin role | <pre>object({<br/>    type        = string<br/>    identifier  = string<br/>    displayName = string<br/>    username    = optional(string)<br/>    email       = optional(string)<br/>    euid        = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | This name will be used for the projects, AKS namespaces & GitHub repository | `string` | n/a | yes |
| <a name="input_workspace_identifier"></a> [workspace\_identifier](#input\_workspace\_identifier) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dev-link"></a> [dev-link](#output\_dev-link) | Link to the dev environment Angular app |
| <a name="output_prod-link"></a> [prod-link](#output\_prod-link) | Link to the prod environment Angular app |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary with next steps and insights into created resources |
<!-- END_TF_DOCS -->

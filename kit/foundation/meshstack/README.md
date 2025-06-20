---
name: foundation/meshstack
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# foundation/meshstack

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 3.0.2 |
| <a name="requirement_meshstack"></a> [meshstack](#requirement\_meshstack) | ~> 0.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [meshstack_project.buildingblocks-testing](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.likvid_gov_guard_dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.likvid_gov_guard_prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.m25_online_banking_app](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.quickstart](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.sap_core_platform](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project.static-website-assets](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project) | resource |
| [meshstack_project_user_binding.likvid_gov_guard_dev_project_admins](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_project_user_binding.likvid_gov_guard_prod_project_admins](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_project_user_binding.m25_online_banking_app_admins](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_project_user_binding.sap_core_platform_project_admins](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_project_user_binding.static_website_assets_project_admins](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/project_user_binding) | resource |
| [meshstack_tag_definition.BusinessUnit](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tag_definition) | resource |
| [meshstack_tag_definition.security_contact](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tag_definition) | resource |
| [meshstack_tenant.buildingblocks-testing-aws](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.buildingblocks-testing-gcp](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.likvid_gov_guard_dev](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.likvid_gov_guard_prod](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.m25_online_banking_app](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.m25_online_banking_app_docs_repo](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.quickstart_aws](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.sap_core_platform](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [meshstack_tenant.static-website-assets](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/tenant) | resource |
| [terraform_data.meshobjects_import](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_meshpanel_base_url"></a> [meshpanel\_base\_url](#input\_meshpanel\_base\_url) | Base URL of the meshPanel | `string` | `null` | no |
| <a name="input_meshstack_api"></a> [meshstack\_api](#input\_meshstack\_api) | API user with access to meshStack | <pre>object({<br/>    endpoint = string,<br/>    username = string,<br/>    password = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_guides_md"></a> [documentation\_guides\_md](#output\_documentation\_guides\_md) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_meshobjects"></a> [meshobjects](#output\_meshobjects) | n/a |
<!-- END_TF_DOCS -->

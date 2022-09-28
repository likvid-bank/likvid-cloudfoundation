---
name: Azure Tenant Configuration
summary: |
  applies AAD tenant-level configuration. This includes organization policies and other key settings affecting
  all cloud infrastructure in this tenant.
compliance:
- control: cfmm/security-and-compliance/resource-policies-blacklisting
  statement: |
    A service control policy denies access to any non-EU Azure regions.
---

# Azure Tenant Configuration

In Azure, the AAD tenant is its own concept.

::: tip
Keep in mind that every tenant has a "root management group", sitting at the top of the management group hierarchy.
The `id` of this management group is equal to the AAD tenant id.
:::
c

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_billing_admins"></a> [billing\_admins](#module\_billing\_admins) | ./billing-admins | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.landingzones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group_policy_assignment.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_policy_assignment.allowed_locations_resource_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_role_assignment.foundation_browsers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.foundation_platform_browser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [local_file.output_md](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [azuread_users.foundation_browser_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azurerm_management_group.root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_policy_definition.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.allowed_locations_resource_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_role_definition.platform_browser_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_tenant_id"></a> [aad\_tenant\_id](#input\_aad\_tenant\_id) | Id of the AAD Tenant. This is also the simultaneously the id of the root management group. | `string` | n/a | yes |
| <a name="input_allowed_locations"></a> [allowed\_locations](#input\_allowed\_locations) | Allowed Azure regions. | `list(string)` | n/a | yes |
| <a name="input_billing_users"></a> [billing\_users](#input\_billing\_users) | The list of users identified by their UPN that shall be granted billing access | <pre>list(object({<br>    email = string,<br>    upn   = string,<br>  }))</pre> | `[]` | no |
| <a name="input_foundation_browser_members"></a> [foundation\_browser\_members](#input\_foundation\_browser\_members) | IAM members for the foundation browser role | <pre>list(object({<br>    email = string,<br>    upn   = string,<br>  }))</pre> | n/a | yes |
| <a name="input_output_md_file"></a> [output\_md\_file](#input\_output\_md\_file) | location of the file where this cloud foundation kit module generates its documentation output | `string` | n/a | yes |
| <a name="input_platform_management_group_name"></a> [platform\_management\_group\_name](#input\_platform\_management\_group\_name) | Create a management group of the specified name and treat it as the root of all resources managed as part of this kit.<br>    This managment group will sit directly below the root management group (AAD Tenant).<br>    This is good for separationg, in particular if you don't have exclusive control over the AAD Tenant because<br>    it is supporting non-cloudfoundation workloads as well. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_management_group_id"></a> [admin\_management\_group\_id](#output\_admin\_management\_group\_id) | id of the admin management group |
| <a name="output_landingzones_management_group_id"></a> [landingzones\_management\_group\_id](#output\_landingzones\_management\_group\_id) | id of the landingzones management group |
| <a name="output_platform_management_group_id"></a> [platform\_management\_group\_id](#output\_platform\_management\_group\_id) | n/a |
<!-- END_TF_DOCS -->
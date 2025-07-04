---
name: GCP Organization Setup
summary: |
  configures organization wide policies.
---

# GCP Organization Setup

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_allowed-policy-member-domains"></a> [allowed-policy-member-domains](#module\_allowed-policy-member-domains) | terraform-google-modules/org-policy/google | ~> 5.1.0 |
| <a name="module_allowed-policy-resource-locations"></a> [allowed-policy-resource-locations](#module\_allowed-policy-resource-locations) | terraform-google-modules/org-policy/google | ~> 5.1.0 |

## Resources

| Name | Type |
|------|------|
| [google_folder.admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder.data_lagoon](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder.dev](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder.prod](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_project.foundation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_folder.parent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder) | data source |
| [google_organization.orgs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_customer_ids_to_allow"></a> [customer\_ids\_to\_allow](#input\_customer\_ids\_to\_allow) | The list of Google Customer Ids to allow users from. | <pre>list(object(<br/>    {<br/>      domain      = string<br/>      customer_id = string<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_domains_to_allow"></a> [domains\_to\_allow](#input\_domains\_to\_allow) | The list of domains to allow users from. This list is concatenated to customer\_ids\_to\_allow | `list(string)` | n/a | yes |
| <a name="input_foundation"></a> [foundation](#input\_foundation) | name of the foundation | `string` | n/a | yes |
| <a name="input_foundation_project_id"></a> [foundation\_project\_id](#input\_foundation\_project\_id) | Project ID of the GCP Project hosting foundation-level resources for this foundation | `string` | n/a | yes |
| <a name="input_parent_folder_id"></a> [parent\_folder\_id](#input\_parent\_folder\_id) | Folder id of the parent folder hosting this foundation.<br/>    This is good for separation, in particular if you don't have exclusive control over the GCP organization because<br/>    it is supporting non-cloudfoundation workloads as well. | `string` | n/a | yes |
| <a name="input_resource_locations_to_allow"></a> [resource\_locations\_to\_allow](#input\_resource\_locations\_to\_allow) | The list of resource locations to allow | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_folder_id"></a> [admin\_folder\_id](#output\_admin\_folder\_id) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_likvid_dev_folder_id"></a> [likvid\_dev\_folder\_id](#output\_likvid\_dev\_folder\_id) | n/a |
| <a name="output_likvid_prod_folder_id"></a> [likvid\_prod\_folder\_id](#output\_likvid\_prod\_folder\_id) | n/a |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | n/a |
| <a name="output_root_folder_id"></a> [root\_folder\_id](#output\_root\_folder\_id) | n/a |
<!-- END_TF_DOCS -->
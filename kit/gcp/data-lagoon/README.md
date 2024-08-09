---
name: Likvid Data Lagoon
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# Likvid Data Lagoon

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 5.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_warehouse"></a> [data\_warehouse](#module\_data\_warehouse) | terraform-google-modules/bigquery/google//modules/data_warehouse | n/a |

## Resources

| Name | Type |
|------|------|
| [google_folder.data_lagoon](https://registry.terraform.io/providers/hashicorp/google/5.40.0/docs/resources/folder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_parent_folder_id"></a> [parent\_folder\_id](#input\_parent\_folder\_id) | The parent folder ID for the Data Lagoon Landing Zone | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID where the Data Lagoon Infrastructure is hosted | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigquery_editor_url"></a> [bigquery\_editor\_url](#output\_bigquery\_editor\_url) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_ds_friendly_name"></a> [ds\_friendly\_name](#output\_ds\_friendly\_name) | n/a |
| <a name="output_folder_id"></a> [folder\_id](#output\_folder\_id) | n/a |
| <a name="output_lookerstudio_report_url"></a> [lookerstudio\_report\_url](#output\_lookerstudio\_report\_url) | n/a |
| <a name="output_raw_bucket"></a> [raw\_bucket](#output\_raw\_bucket) | n/a |
<!-- END_TF_DOCS -->
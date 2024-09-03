---
name: gcp/buildingblock-backplane
summary: |
  Sets up a simple automation infrastructure for building blocks.
---

# gcp/buildingblock-backplane

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_folder_iam_binding.servicemanagement](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_iam_binding.serviceusage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_project_iam_binding.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_service_account.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backplane-service-account-credentials"></a> [backplane-service-account-credentials](#output\_backplane-service-account-credentials) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
<!-- END_TF_DOCS -->

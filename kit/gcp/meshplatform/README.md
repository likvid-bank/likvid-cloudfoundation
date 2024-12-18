---
name: GCP meshPlatform
summary: |
  integrates this platform with meshStack as a meshPlatform to enable self-service for our engineering teams.
# optional: add additional metadata about implemented security controls
---

# GCP meshPlatform

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_meshplatform"></a> [meshplatform](#module\_meshplatform) | meshcloud/meshplatform/gcp | 0.3.0 |

## Resources

| Name | Type |
|------|------|
| [google_project.meshstack_root](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account_id"></a> [billing\_account\_id](#input\_billing\_account\_id) | The GCP billing account in your organization. | `string` | n/a | yes |
| <a name="input_billing_org_id"></a> [billing\_org\_id](#input\_billing\_org\_id) | GCP organization ID that holds billing account. | `string` | n/a | yes |
| <a name="input_can_delete_projects_in_landing_zone_folder_ids"></a> [can\_delete\_projects\_in\_landing\_zone\_folder\_ids](#input\_can\_delete\_projects\_in\_landing\_zone\_folder\_ids) | GCP Folders that make up Landing Zone. The service account will receive permissions to delete projects on these folders. | `list(string)` | `[]` | no |
| <a name="input_carbon_export_module_enabled"></a> [carbon\_export\_module\_enabled](#input\_carbon\_export\_module\_enabled) | Determines whether or not to include the resources of the carbon footprint export module. | `bool` | `false` | no |
| <a name="input_carbon_footprint_dataset_id"></a> [carbon\_footprint\_dataset\_id](#input\_carbon\_footprint\_dataset\_id) | Id of BigQuery dataset for carbon footprint. | `string` | n/a | yes |
| <a name="input_cloud_billing_export_dataset_id"></a> [cloud\_billing\_export\_dataset\_id](#input\_cloud\_billing\_export\_dataset\_id) | GCP BigQuery dataset containing the Cloud Billing BigQuery export. This variable is only required to form the output for meshPlatform configuration. No resources are created or attached. | `string` | n/a | yes |
| <a name="input_cloud_billing_export_project_id"></a> [cloud\_billing\_export\_project\_id](#input\_cloud\_billing\_export\_project\_id) | GCP Project where the BiqQuery table resides that holds the Cloud Billing export to BigQuery. See https://cloud.google.com/billing/docs/how-to/export-data-bigquery | `string` | n/a | yes |
| <a name="input_cloud_billing_export_table_id"></a> [cloud\_billing\_export\_table\_id](#input\_cloud\_billing\_export\_table\_id) | GCP BigQuery table containing the Cloud Billing BigQuery export. This variable is only required to form the output for meshPlatform configuration. No resources are created or attached. | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | id of the parent folder to the project (see project\_id) | `string` | n/a | yes |
| <a name="input_kraken_sa_name"></a> [kraken\_sa\_name](#input\_kraken\_sa\_name) | Name of the service account to create for Kraken. | `string` | `"mesh-kraken-service-tf"` | no |
| <a name="input_landing_zone_folder_ids"></a> [landing\_zone\_folder\_ids](#input\_landing\_zone\_folder\_ids) | GCP Folders that make up the Landing Zone. The service account will only receive permissions on these folders. | `list(string)` | n/a | yes |
| <a name="input_landingzone_access"></a> [landingzone\_access](#input\_landingzone\_access) | n/a | <pre>object({<br>    functions = list(object({<br>      function = string<br>      region   = string<br>      project  = string<br>    }))<br>    gdm_templates = list(object({<br>      project     = string<br>      bucket_name = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | GCP Organization ID that holds the projects that generate billing data that the service account should import. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID where to create the resources. This is typically a 'meshstack-root' project. | `string` | n/a | yes |
| <a name="input_replicator_sa_name"></a> [replicator\_sa\_name](#input\_replicator\_sa\_name) | Name of the service account to create for Replicator. | `string` | `"mesh-replicator-service-tf"` | no |
| <a name="input_service_account_keys"></a> [service\_account\_keys](#input\_service\_account\_keys) | Create service account keys for authentication. | `bool` | `true` | no |
| <a name="input_workload_identity_federation"></a> [workload\_identity\_federation](#input\_workload\_identity\_federation) | Setup workload identity federation for authentication. | <pre>object({<br>    workload_identity_pool_identifier = string<br>    issuer                            = string<br>    audience                          = string<br>    replicator_subject                = string<br>    kraken_subject                    = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_meshplatform_configuration"></a> [meshplatform\_configuration](#output\_meshplatform\_configuration) | n/a |
<!-- END_TF_DOCS -->
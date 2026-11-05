# OCI Security Module

This module configures security monitoring and compliance controls for Oracle Cloud Infrastructure (OCI).

## Features

- **Audit Log Retention**: Sets audit log retention policy at tenancy level (365 days)
- **Event Monitoring**: Optional audit log event forwarding for critical security events
- **Vulnerability Scanning**: Configures host and container vulnerability scanning recipes in foundation compartment

## Prerequisites

- Foundation compartment created (done in bootstrap module)
- For audit log forwarding: A streaming service must be created and its OCID provided

## Usage

Deployed via Terragrunt. See `terragrunt.hcl` for configuration.

## Outputs

- `audit_retention_days`: Configured audit log retention period
- `host_scan_recipe_id`: OCID of the host vulnerability scanning recipe
- `container_scan_recipe_id`: OCID of the container vulnerability scanning recipe

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_audit_configuration.audit_retention](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/audit_configuration) | resource |
| [oci_events_rule.audit_log_events](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/events_rule) | resource |
| [oci_vulnerability_scanning_container_scan_recipe.default](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/vulnerability_scanning_container_scan_recipe) | resource |
| [oci_vulnerability_scanning_host_scan_recipe.default](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/vulnerability_scanning_host_scan_recipe) | resource |
| [oci_identity_tenancy.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tenancy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audit_log_stream_id"></a> [audit\_log\_stream\_id](#input\_audit\_log\_stream\_id) | OCID of the stream to forward audit logs to (required if enable\_audit\_log\_forwarding is true) | `string` | `null` | no |
| <a name="input_audit_retention_days"></a> [audit\_retention\_days](#input\_audit\_retention\_days) | Number of days to retain audit logs (minimum 90 for CIS compliance) | `number` | `365` | no |
| <a name="input_enable_audit_log_forwarding"></a> [enable\_audit\_log\_forwarding](#input\_enable\_audit\_log\_forwarding) | Enable audit log event forwarding to streaming service | `bool` | `false` | no |
| <a name="input_foundation_compartment_ocid"></a> [foundation\_compartment\_ocid](#input\_foundation\_compartment\_ocid) | The OCID of the foundation compartment | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the OCI tenancy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_audit_retention_days"></a> [audit\_retention\_days](#output\_audit\_retention\_days) | Configured audit log retention period in days |
| <a name="output_container_scan_recipe_id"></a> [container\_scan\_recipe\_id](#output\_container\_scan\_recipe\_id) | OCID of the container vulnerability scanning recipe |
| <a name="output_host_scan_recipe_id"></a> [host\_scan\_recipe\_id](#output\_host\_scan\_recipe\_id) | OCID of the host vulnerability scanning recipe |
<!-- END_TF_DOCS -->
# OCI Bootstrap Module

This module sets up the foundational IAM structure for Oracle Cloud Infrastructure (OCI) within a foundation compartment.

## Features

- **IAM Groups**: Creates platform engineering group at tenancy level (OCI requirement)
- **Access Policies**: Configures policies scoped to foundation compartment for safe testing

## Prerequisites

- OCI tenancy with admin access
- Foundation compartment already created
- User OCIDs for platform engineers team members (optional)

## Usage

Deployed via Terragrunt. See `terragrunt.hcl` for configuration.

## Outputs

- `tenancy_ocid`: OCID of the tenancy
- `foundation_compartment_ocid`: OCID of the foundation compartment
- `foundation_name`: Name of the foundation
- `platform_engineers_group_id`: OCID of the created platform engineers group
- `platform_engineers_group_name`: Name of the platform engineers group

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_group.platform_engineers](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_group) | resource |
| [oci_identity_policy.platform_engineers](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_user_group_membership.platform_engineers](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_user_group_membership) | resource |
| [oci_identity_compartment.foundation](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartment) | data source |
| [oci_identity_tenancy.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tenancy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation_compartment_ocid"></a> [foundation\_compartment\_ocid](#input\_foundation\_compartment\_ocid) | The OCID of the foundation compartment where resources will be created | `string` | n/a | yes |
| <a name="input_foundation_name"></a> [foundation\_name](#input\_foundation\_name) | Name of the foundation (used for naming resources) | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The home region of the OCI tenancy | `string` | n/a | yes |
| <a name="input_platform_engineers_group"></a> [platform\_engineers\_group](#input\_platform\_engineers\_group) | Platform engineers group configuration with name and member user OCIDs | <pre>object({<br/>    name    = string<br/>    members = set(string)<br/>  })</pre> | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The OCID of the OCI tenancy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_foundation_compartment_ocid"></a> [foundation\_compartment\_ocid](#output\_foundation\_compartment\_ocid) | The OCID of the foundation compartment |
| <a name="output_foundation_name"></a> [foundation\_name](#output\_foundation\_name) | Name of the foundation |
| <a name="output_platform_engineers_group_id"></a> [platform\_engineers\_group\_id](#output\_platform\_engineers\_group\_id) | OCID of the platform engineers group |
| <a name="output_platform_engineers_group_name"></a> [platform\_engineers\_group\_name](#output\_platform\_engineers\_group\_name) | Name of the platform engineers group |
| <a name="output_tenancy_ocid"></a> [tenancy\_ocid](#output\_tenancy\_ocid) | The OCID of the OCI tenancy |
<!-- END_TF_DOCS -->
# OCI Cloud-Native Landing Zone

This module creates a landing zone for cloud-native application workloads in Oracle Cloud Infrastructure (OCI).

## Features

- **Compartment Structure**: Creates a three-tier compartment hierarchy (cloud-native → dev/prod)
- **IAM Policies**: Configures access policies for users and administrators (requires groups to exist)
- **Environment Separation**: Separates development and production workloads

## Architecture

```
<foundation>-cloud-native/
├── dev/          # Development environment
└── prod/         # Production environment
```

## Prerequisites

- Foundation compartment created (configured in bootstrap module)
- IAM groups created for cloud-native users and admins (must be created manually or in separate module)

## Usage

Deployed via Terragrunt. See `terragrunt.hcl` for configuration.

## Outputs

- `cloud_native_compartment_id`: OCID of the cloud-native root compartment
- `dev_compartment_id`: OCID of the development compartment
- `prod_compartment_id`: OCID of the production compartment
- `policy_id`: OCID of the access policy

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.cloud_native](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_compartment.dev](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_compartment.prod](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_policy.cloud_native_users](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_native_admins_group"></a> [cloud\_native\_admins\_group](#input\_cloud\_native\_admins\_group) | Name of the IAM group for cloud-native administrators | `string` | `"cloud-native-admins"` | no |
| <a name="input_cloud_native_users_group"></a> [cloud\_native\_users\_group](#input\_cloud\_native\_users\_group) | Name of the IAM group for cloud-native users with dev access | `string` | `"cloud-native-users"` | no |
| <a name="input_foundation"></a> [foundation](#input\_foundation) | Name of the foundation | `string` | n/a | yes |
| <a name="input_parent_compartment_id"></a> [parent\_compartment\_id](#input\_parent\_compartment\_id) | OCID of the parent compartment (typically the tenancy root compartment) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_native_compartment_id"></a> [cloud\_native\_compartment\_id](#output\_cloud\_native\_compartment\_id) | OCID of the cloud-native root compartment |
| <a name="output_dev_compartment_id"></a> [dev\_compartment\_id](#output\_dev\_compartment\_id) | OCID of the development compartment |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | OCID of the cloud-native users policy |
| <a name="output_prod_compartment_id"></a> [prod\_compartment\_id](#output\_prod\_compartment\_id) | OCID of the production compartment |
<!-- END_TF_DOCS -->
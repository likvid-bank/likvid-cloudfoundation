# OCI Sandbox Landing Zone

This module creates a sandbox landing zone for experimentation and learning in Oracle Cloud Infrastructure (OCI).

## Features

- **Single Compartment**: Creates a flat sandbox compartment for experimentation
- **Limited Permissions**: Grants users access to common resources (compute, networking, storage, object storage)
- **Safe Environment**: Isolated from other workloads within foundation compartment

## Architecture

```
<foundation>-sandbox/          # Sandbox environment for experimentation
```

## Prerequisites

- Foundation compartment created (configured in bootstrap module)
- IAM group created for sandbox users (must be created manually or in separate module)

## Usage

Deployed via Terragrunt. See `terragrunt.hcl` for configuration.

## Permissions Granted

Sandbox users can manage:
- Compute instances
- Virtual networks (VCNs, subnets, route tables, etc.)
- Block and boot volumes
- Object storage buckets and objects

Sandbox users have read-only access to all other resources in the compartment.

## Outputs

- `sandbox_compartment_id`: OCID of the sandbox compartment
- `policy_id`: OCID of the sandbox users policy

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.sandbox](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_policy.sandbox_users](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation"></a> [foundation](#input\_foundation) | Name of the foundation | `string` | n/a | yes |
| <a name="input_parent_compartment_id"></a> [parent\_compartment\_id](#input\_parent\_compartment\_id) | OCID of the parent compartment (typically the tenancy root compartment) | `string` | n/a | yes |
| <a name="input_sandbox_users_group"></a> [sandbox\_users\_group](#input\_sandbox\_users\_group) | Name of the IAM group for sandbox users | `string` | `"sandbox-users"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | OCID of the sandbox users policy |
| <a name="output_sandbox_compartment_id"></a> [sandbox\_compartment\_id](#output\_sandbox\_compartment\_id) | OCID of the sandbox compartment |
<!-- END_TF_DOCS -->
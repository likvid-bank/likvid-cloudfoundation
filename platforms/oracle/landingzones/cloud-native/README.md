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

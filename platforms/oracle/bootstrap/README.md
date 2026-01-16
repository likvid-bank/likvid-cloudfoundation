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

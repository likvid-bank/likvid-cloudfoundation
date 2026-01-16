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

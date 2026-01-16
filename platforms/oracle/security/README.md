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

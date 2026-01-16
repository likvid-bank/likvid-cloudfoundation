# OCI Application Compartment Building Block

Creates an application compartment with IAM groups and policies for team-based access control.

## Features

- **Application Compartment**: Creates a compartment for application workloads
- **IAM Groups**: Three groups with different access levels (readers, users, admins)
- **Access Policies**: Granular permissions for each group

## Access Levels

### Readers
- Read-only access to all resources in the compartment

### Users
- Manage compute instances, storage, networking, and load balancers
- Read all resources

### Admins
- Full management access to all resources in the compartment

## Usage

Deployed via Terragrunt. See example configuration for inputs.

## Outputs

- `compartment_id`: OCID of the application compartment
- `reader_group_id`, `user_group_id`, `admin_group_id`: Group OCIDs
- `policy_id`: OCID of the access policy

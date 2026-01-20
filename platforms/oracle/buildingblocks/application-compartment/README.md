# OCI Application Compartment Building Block

Creates an application compartment with IAM groups and policies for team-based access control.

## Features

- **Application Compartment**: Creates a compartment for application workloads
- **Conditional Placement**: Places compartments based on meshStack project tags
- **Flexible Configuration**: Tag names and compartment mappings configurable via YAML
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

## Compartment Placement Logic

The module determines the parent compartment based on meshStack project tags configured in the `tag_relations` variable:

1. **Sandbox Landing Zone**: Always uses sandbox compartment, regardless of environment
2. **Cloud-Native Landing Zone**: Uses environment-specific compartments (dev/qa/test/prod)
3. **Fallback**: Uses default compartment if no tags match

## Usage

### Basic Usage

```hcl
module "application_compartment" {
  source = "./application-compartment"

  tenancy_ocid = var.tenancy_ocid
  foundation   = "my-foundation"
  workspace_id = "my-workspace"
  project_id   = "my-project"
  region       = "eu-frankfurt-1"
  users        = var.users
}
```

The module uses default tag names (`Environment`, `landingzone_family`) and placeholder compartment IDs.

### Custom Configuration

Override the `tag_relations` variable to customize tag names and compartment mappings:

```hcl
module "application_compartment" {
  source = "./application-compartment"

  tenancy_ocid = var.tenancy_ocid
  foundation   = "my-foundation"
  workspace_id = "my-workspace"
  project_id   = "my-project"
  region       = "eu-frankfurt-1"
  users        = var.users

  tag_relations = <<-EOT
    # meshStack tag names to read
    tag_names:
      environment: "Environment"
      landing_zone: "landingzone_family"

    # Landing zone configurations
    landing_zones:
      # Sandbox: single compartment for all environments
      sandbox:
        compartment_id: "ocid1.compartment.oc1..aaaaaaaa...sandbox"
      
      # Cloud-native: per-environment compartments
      cloud-native:
        environments:
          dev:
            compartment_id: "ocid1.compartment.oc1..aaaaaaaa...cloudnative-dev"
          qa:
            compartment_id: "ocid1.compartment.oc1..aaaaaaaa...cloudnative-qa"
          test:
            compartment_id: "ocid1.compartment.oc1..aaaaaaaa...cloudnative-test"
          prod:
            compartment_id: "ocid1.compartment.oc1..aaaaaaaa...cloudnative-prod"

    # Fallback if no match
    default_compartment_id: "ocid1.compartment.oc1..aaaaaaaa...default"
  EOT
}
```

## Configuration Structure

The `tag_relations` variable accepts YAML with the following structure:

```yaml
# Which meshStack tags to read
tag_names:
  environment: "Environment"              # Tag name for environment
  landing_zone: "landingzone_family"      # Tag name for landing zone family

# Compartment mappings per landing zone
# The landing zone names here match the values in your meshStack tags
landing_zones:
  sandbox:                                # When landing_zone tag = "sandbox"
    compartment_id: "ocid1.compartment..."  # Single compartment (no environments)
  
  cloud-native:                           # When landing_zone tag = "cloud-native"
    environments:                         # Per-environment compartments
      dev:
        compartment_id: "ocid1.compartment..."
      qa:
        compartment_id: "ocid1.compartment..."
      test:
        compartment_id: "ocid1.compartment..."
      prod:
        compartment_id: "ocid1.compartment..."

# Default fallback compartment
default_compartment_id: "ocid1.compartment..."
```

**Important**: 
- The keys under `landing_zones` (e.g., `sandbox`, `cloud-native`) must match the **values** in your meshStack `landingzone_family` tag
- Landing zones without an `environments` section will use the same compartment for all environments
- Landing zones with an `environments` section will route based on the environment tag value

## meshStack Integration

The module automatically:
1. Fetches project metadata from meshStack using `workspace_id` and `project_id`
2. Reads tags from the project (format: `map(list(string))`)
3. Extracts tag values based on `tag_names` configuration
4. Selects the appropriate compartment based on landing zone and environment

## Example Tag Scenarios

| meshStack Tags | Selected Compartment |
|----------------|---------------------|
| `landingzone_family: ["sandbox"]`, `Environment: ["dev"]` | `landing_zones.sandbox.compartment_id` |
| `landingzone_family: ["sandbox"]`, `Environment: ["prod"]` | `landing_zones.sandbox.compartment_id` |
| `landingzone_family: ["cloud-native"]`, `Environment: ["dev"]` | `landing_zones.cloud-native.environments.dev.compartment_id` |
| `landingzone_family: ["cloud-native"]`, `Environment: ["prod"]` | `landing_zones.cloud-native.environments.prod.compartment_id` |
| No matching tags | `default_compartment_id` |

## Outputs

- `compartment_id`: OCID of the application compartment
- `compartment_name`: Name of the application compartment
- `reader_group_id`, `user_group_id`, `admin_group_id`: Group OCIDs
- `reader_group_name`, `user_group_name`, `admin_group_name`: Group names
- `policy_id`: OCID of the access policy
- `console_url`: Direct link to the compartment in OCI Console

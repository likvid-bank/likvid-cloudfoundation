# End-to-End Platform Setup with Infrastructure as Code

The ${md_workspace_m25_platform_team} is expanding their cloud platform offerings to include an Azure Kubernetes Cluster (AKS).
They want to set up the entire platform—from Azure/K8S infrastructure to meshStack configuration—using Infrastructure as
Code to ensure repeatability, auditability, and consistency.

## Motivation / Business Context

As part of Likvid Bank's cloud strategy, the M25 Platform Team needs to onboard AKS as a new platform.
Their goal is to provide Kubernetes namespaces to application teams through meshStack's self-service portal
while maintaining strong governance and compliance controls.

The team wants to manage everything as code:

- Azure Integration Resources (service principals, permissions, management groups)
- Kubernetes Integration Resources (service accounts, role bindings)
- Integration of the AKS Platform in meshStack
- Landing Zones

## Challenges

- **Manual Setup is Time-Consuming**: Setting up platforms manually involves many steps across different tools
- **Configuration Drift**: Hard to keep infrastructure and platform configuration in sync
- **No Audit Trail**: Difficult to track who made what changes and when
- **Not Repeatable**: Can't easily replicate the setup for different environments or regions

## End-to-End Implementation

The M25 Platform Team will implement the complete platform setup using Terraform, leveraging the [meshStack Terraform Provider](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs).

### Prerequisites

For this guide, you will need:

- Access to the ${md_workspace_m25_platform_team} workspace in meshStack
- An API Key that has read, write, delete permissions for platforms and landing zones in meshStack in the workspace
- Azure CLI authenticated with permissions to create resources in the target subscription
- kubectl configured to access the target AKS cluster
- OpenTofu installed locally to execute Terraform code

### Step 1: Set up the AKS Platform Snippet

There is pre-built snippet on the meshStack Hub for AKS Integrations into meshStack. This snippet takes care of all
necessary work to set up a fully working platform integration for AKS, including:

- Setting up the [meshPlatform module](https://github.com/meshcloud/terraform-aks-meshplatform) which will do all
  necessary setup work in Azure & Kubernetes.
- Creating a platform using the configuration from the meshPlatform module.
- Creating a basic AKS landing zone.

The AKS Platform Integration snippet can be found [here](https://hub.meshcloud.io/platforms/aks/integrate)
and should be copied into a local file. There are also some necessary changes that need to be made to make the Terraform
code work. The following changes need to be made:

- A meshStack API Key needs to be configured under the `provider "meshstack"` block.
  - If you don't have an API Key already, create on in meshStack and copy it into the provider block or set it as an environment variable.
- Make sure you are logged in with your Azure CLI and have sufficient permission in the target subscription.
- Make sure you are logged in with your kubectl and have access to the target AKS cluster. Also make sure you configure the provider to use this cluster.
- Under `locals` update the `aks_base_url` to `https://dev-oug61sf3.hcp.germanywestcentral.azmk8s.io`.
- Under `locals` update the `aks_subscription_id` to `7490f509-073d-42cd-a720-a7f599a3fd0b`.
- Under `locals` update the `aks_cluster_name` to `aks`.
- Under `locals` update the `aks_resource_group` to `aks-rg`.
- Under `locals` update the `aks_platform_workspace` to `m25-platform`.
- Under `module "aks_meshplatform"` we need to add two additional variables because the roles in the cluster already exist. Add these two lines at the end of the module block:
```hcl
  existing_clusterrole_name_metering = "meshfed-metering"
  existing_clusterrole_name_replicator = "meshfed-service"
```


### Step 2: Execute the Terraform Code

Now that the Terraform code is ready, the team can execute it. Simply follow the following steps and monitor for any errors:

- Initialize the Terraform working directory:
```bash
tofu init
```
- Plan the Terraform changes to see what will be created:
```bash
tofu plan
```
- Apply the Terraform configuration to create the infrastructure and platform:
```bash
tofu apply
```

### Step 3: Verify the Platform Integration

The team verifies the setup by logging into meshPanel. The AKS Platform should now be available, including a landing zone.

## Testing the Platform

The platform team can now test the platform by creating a new project and provisioning an AKS namespace:

1. Navigate to the workspace in meshPanel
2. Create a new project
3. Select the ${md_platform_azure_m25} platform
4. Continue the wizard and finish the process.
5. Within minutes, they have a fully provisioned Azure subscription

### Managing Changes

Thanks to the Terraform code, any changes to the platform configuration can be made in a controlled manner.
For example, if the team needs to update support URLs or add new features to the platform, they can simply update the
Terraform code and apply the changes.

#### Updating Configuration

When the team needs to update platform configuration (like support URLs or descriptions), they:

1. Update the values in the Terraform code above
2. Execute a `tofu plan` to review the changes
3. Apply the changes with `tofu apply`
4. ✅ The platform is updated in meshStack with the new configuration

## Conclusion

Thanks to the platform Terraform snippet from meshStack Hub and the meshStack Terraform provider,
the ${md_workspace_m25_platform_team} has achieved:

- **Speed**: Rapidly set up a new platform integration in minutes instead of hours/days
- **Auditability**: Complete history of all configuration changes in Git
- **Repeatability**: Easy to replicate the setup across multiple meshStack environments
- **Automation**: Terraform allows for integration of platform configuration into CI/CD pipelines
- **Consistency**: Infrastructure and platform configuration are tightly coupled and version-controlled together

The team can now confidently scale their platform offerings, knowing that everything is managed as code.

:::tip
Want to learn more about the meshStack Terraform Provider?

- [Provider Documentation](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs)
- [meshstack_platform Resource](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/platform)
- [meshstack_landingzone Resource](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/landingzone)

:::

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
- An API Key in meshStack that has the following permissions:
  - read, write, delete for platforms in workspace
  - read, write, delete for landing zones in workspace
  - read integrations in workspace
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
  For example, you can use this provider config if you are authenticated via kubectl:
  ```hcl
  provider "kubernetes" {
    config_path    = "~/.kube/config"
    config_context = "aks"
  }
  ```
- We also need to set the local variables correctly. You can copy the following locals block and replace it in the code:
  ```hcl
  locals {

    # Existing AKS cluster config.
    aks_base_url        = "https://dev-oug61sf3.hcp.germanywestcentral.azmk8s.io"
    aks_subscription_id = "7490f509-073d-42cd-a720-a7f599a3fd0b"
    aks_cluster_name    = "aks"
    aks_resource_group  = "aks-rg"

    # meshStack workspace that will manage the platform
    aks_platform_workspace  = "m25-platform"
    aks_platform_identifier = "aks-likvid-demo-story" # NOTE: This one is already used, make sure to change it!
    aks_location_identifier = "global"
  }
  ```
- Under `module "aks_meshplatform"` we need to add four additional variables because the roles in the cluster already exist. Add these four lines at the end of the module block:
  ```hcl

    # This makes sure the role binding does not conflict with the existing one
    kubernetes_name_suffix_metering = "meshfed-metering-demo-story"
    kubernetes_name_suffix_replicator = "meshfed-service-demo-story"

    # This makes sure the module reuses the existing role in the cluster
    existing_clusterrole_name_metering = "meshfed-metering"
    existing_clusterrole_name_replicator = "meshfed-service"
  ```
- In the `module "aks_meshplatform"` also make sure to set the `namespace` variable to something else to prevent conflicts. For example pick:
  ```hcl
    namespace = "meshcloud-aks-demo-story"
  ```
- Make sure the platform will be unpublished (meaning in a draft state). To do so replace the availability block in the `meshstack_platform` resource with the following code:
  ```hcl
    availability = {
      restricted_to_workspaces = [local.aks_platform_workspace]
      restriction       = "PRIVATE"
      publication_state = "UNPUBLISHED"
    }
  ```
- Make sure you set all mandatory tags for the landing zone resource. At the moment of writing these are the
  only mandatory tags. Add the following block to the `meshstack_landingzone` resource under `metadata.tags`:
  ```hcl
    tags = {
      "LandingZoneFamily" = ["container-platform"]
    }
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

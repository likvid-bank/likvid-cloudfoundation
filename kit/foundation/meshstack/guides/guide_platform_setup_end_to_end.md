# End-to-End Platform Setup with Infrastructure as Code

The ${md_workspace_m25_platform_team} is expanding their cloud platform offerings to include Microsoft Azure. They want to set up the entire platform—from Azure infrastructure to meshStack configuration—using Infrastructure as Code to ensure repeatability, auditability, and consistency.

## Motivation / Business Context

As part of Likvid Bank's multi-cloud strategy, the M25 Platform Team needs to onboard Microsoft Azure as a new platform. Their goal is to provide Azure services to application teams through meshStack's self-service portal while maintaining strong governance and compliance controls.

The team wants to manage everything as code:

- Azure infrastructure (service principals, permissions, management groups)
- Platform registration in meshStack
- Landing zones with appropriate governance policies
- Access controls through tags and policies

## Challenges

- **Manual Setup is Time-Consuming**: Setting up platforms manually involves many steps across different tools
- **Configuration Drift**: Hard to keep infrastructure and platform configuration in sync
- **No Audit Trail**: Difficult to track who made what changes and when
- **Not Repeatable**: Can't easily replicate the setup for different environments or regions

## End-to-End Implementation

The M25 Platform Team implements the complete platform setup using Terraform and Terragrunt, leveraging the [meshStack Terraform Provider](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs).

### Step 1: Deploy Azure Infrastructure

First, the team deploys the foundational Azure infrastructure using the `kit/azure/meshplatform` module:

```bash
cd foundations/likvid-prod/platforms/azure/meshplatform
terragrunt apply
```

This creates:

- Service Principals for meshStack (replicator and metering)
- Required role assignments and permissions
- Azure AD application registrations

The outputs (tenant ID, credentials) are automatically captured by Terraform state for use in the next step.

### Step 2: Deploy Landing Zone Infrastructure

Next, they create the Azure landing zone infrastructure using the `kit/azure/landingzones/sandbox` module:

```bash
cd foundations/likvid-prod/platforms/azure/landingzones/sandbox
terragrunt apply
```

This creates:

- Azure Management Group for the landing zone
- Governance policies and compliance controls
- Resource location restrictions

The management group ID is output for use in meshStack configuration.

### Step 3: Configure Platform and Landing Zones in meshStack

With the infrastructure ready, the team enables the Azure M25 platform configuration in their `foundations/likvid-prod/meshstack/terragrunt.hcl`. The configuration automatically references Azure infrastructure outputs via Terragrunt dependencies:

- Azure AD tenant ID from the meshplatform module
- Service principal credentials (client ID, secret, object ID)
- Management group ID from the landing zone module
- Role mappings for meshStack project roles to Azure built-in roles

Then they apply the meshStack configuration:

```bash
cd foundations/likvid-prod/meshstack
terragrunt apply
```

This creates both the `meshstack_platform` and `meshstack_landingzone` resources in a single operation, automatically wiring together all the infrastructure dependencies.

### Step 4: Verify Platform Availability

The team verifies the setup by logging into meshPanel. The Azure M25 platform is now available with the sandbox landing zone ready for use.

## Using the Platform

Application teams from ${md_workspace_m25_online_banking} can now use the platform:

1. Navigate to their workspace in meshPanel
2. Create a new project
3. Select the ${md_platform_azure_m25} platform
4. Choose the **Azure M25 Sandbox** landing zone
5. Within minutes, they have a fully provisioned Azure subscription

## Managing Changes

### Updating Configuration

When the team needs to update platform configuration (like support URLs or descriptions), they:

1. Update the values in `terragrunt.hcl`
2. Create a pull request
3. Review the Terraform plan
4. Merge and apply

All changes are version-controlled with full audit trail.

### Adding More Landing Zones

To add a production landing zone with stricter policies:

1. Deploy production landing zone infrastructure
2. Add production landing zone configuration to `terragrunt.hcl`
3. Apply via Terragrunt

The production landing zone becomes available alongside the sandbox, giving application teams a clear path from development to production.

## Conclusion

By managing their Azure platform and landing zones as code, the ${md_workspace_m25_platform_team} has achieved:

- **Auditability**: Complete history of all configuration changes in Git
- **Repeatability**: Easy to replicate the setup across multiple meshStack environments
- **Quality**: Peer review process catches errors before they reach production
- **Automation**: Integrated platform configuration into their CI/CD pipelines
- **Consistency**: Infrastructure and platform configuration are tightly coupled and version-controlled together

The team can now confidently scale their platform offerings, knowing that every change is reviewed, tested, and documented.

:::tip
Want to learn more about the meshStack Terraform Provider?

- [Provider Documentation](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs)
- [meshstack_platform Resource](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/platform)
- [meshstack_landingzone Resource](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs/resources/landingzone)

:::

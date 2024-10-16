# Business Platforms

This guide shows you how you can solve common integration challenges around "business platforms" with meshStack.

## Motivation

With the cloud foundation team being responsible for building the foundational landing zones for different workload
types, many organizations find the need to build specialized internal platforms dedicated to supporting applications for a specific
line of business. These internal platforms typically have their own platform teams that cater to their customers.

For the scenario in our guide, we suppose that Likvid Bank has recently acquired the [challenger bank](https://en.wikipedia.org/wiki/Challenger_bank) "M25".
The IT Infrastructure of M25 has been built from the ground up on AWS and supported by a dedicated platform team.
Wanting to reap the benefits of the post merger integration, the Likvid Bank board has decided that it will retain
M25's IT platform for its advanced digital capabilities and will continue investing into it.
Nonetheless, Likvid Bank must leverage significant cost synergies from the acuistion. The board has therefore
set the goal of moving M25s existing AWS workload under the Likvid Bank AWS Contract as quickly as possible.
This will allow Likvid Bank to leverage better terms negotiated with AWS.

The Cloud Foundation team is now tasked with establishing a minimum of central governance and compliance management over
M25, while not interfering with their existing operations on AWS.

## Challenges

The Cloud Foundation team has identified the following milestones

- Migrate all of M25s AWS Accounts into the Likvid Bank AWS Organization in a dedicated Organizational Unit (OU)
- Enable the M25 Platform team to offer landing zones and services to their application teams using meshStack
- Onboard existing M25 Applications as Workspaces into meshStack, assign the responsible Owners and ensure all
 regulatory required metadata is present

The team has already completed the first milestone and imported all accounts into the Likvid Bank AWS organization, see
[M25 Platform](/platforms/aws/m25.md).

## Setting Up Tags and Policies

Our goal is to provide the following access in meshStack

- Only Workspaces tagged `M25` are allowed to access `M25` Landing Zones and Building Blocks
- "Untagged" workspaces can access any Landing Zones and Building Blocks (except M25)

To implement this, we set up the following tags + policies

- Tag `${tags_BusinessUnit}` with value `M25` on Workspaces, Landing Zones and Building Block Definitions
- Policy `${policy_RestrictLandingZoneToWorkspaceBusinessUnit}`
- Policy `${policy_RestrictBuildingBlockToWorkspaceBusinessUnit}`

:::tip
You can model the `${tags_BusinessUnit}` tag as an administrative tag, so that its values can only be
set and modified by the cloud foundation team.
:::

To keep it simple, we will model all of these tags as single-select values. Therefore it does not matter (in this case)
whether we choose the [subset](https://docs.meshcloud.io/docs/meshcloud.policies.html#subset) or
[intersection](https://docs.meshcloud.io/docs/meshcloud.policies.html#subset) evaluation strategy.
Thanks to the [null sets rule](https://docs.meshcloud.io/docs/meshcloud.policies.html#policy-evaluation-strategy), all
untagged subjects will pass policy evaluation.

## Onboarding the M25 Platform Team

The Likvid Bank Cloud Foundation Team now creates a dedicated Workspace `${meshobjects_import_workspaces_m25_platform_yml_output_spec_displayName }`
and enables them as a [Landing Zone Contributor]() on the AWS Platform. <!--TODO Link LZ Contributor docs once available-->

The M25 Platform team then proceeds to create its first Landing Zone `${landinZones_m25_cloud_native_spec_displayName}` using the [M25 Platform OU](/platforms/aws/m25.md).
They tag this landing zone `${tags_BusinessUnit}: ${landinZones_m25_cloud_native_spec_tags_BusinessUnit}`.

The M25 Platform team also creates a Building Block Definition `${buildingBlockDefinitions_m25_domain_spec_displayName}`.
This building block allows application teams to ${buildingBlockDefinitions_m25_domain_spec_description}
They tag this building block `${tags_BusinessUnit}: ${buildingBlockDefinitions_m25_domain_spec_tags_businessUnit}`.

## Onboarding an M25 Application Team

To verify that the configured Policies work as intended to deliver the desired application team experience,
we'll create the workspace `${meshstack_project_m25_online_banking_app_spec_display_name}`
and tag it with `${tags_BusinessUnit}: ${meshobjects_import_output_spec_tags_BusinessUnit}")}`.

This workspace now has access to only the `${landinZones_m25_cloud_native_spec_displayName}` Landing Zone and can create tenants on it
as well as use the `${buildingBlockDefinitions_m25_domain_spec_displayName}` Building Block.

:::tip
To verify other workspaces do not have access to the `${landinZones_m25_cloud_native_spec_name}` Landing Zone,
simply use a workspace tagged with a different (or no) `${tags_BusinessUnit}` tag like `${meshobjects_import_workspaces_likvid_mobile_yml_output_spec_displayName}`
and try using any of the M25-specific landing zones or building blocks.
:::

<!-- TODO: describe how to import existing AWS Accounts/Projects-->

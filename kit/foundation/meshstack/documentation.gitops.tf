locals {
  guide_gitops = <<EOF
# Integrating Existing Automation and GitOps Pipelines

This guide shows you how you can solve common scenarios for integrating existing automation and orchestration
solutions with meshStack.

## Motivation

Most platform teams start with building automation using Infrastructure as Code technologies like terraform, Cloud Formation,
ARM Templates or automation scripts (ansible). To execute these automations, teams often times use CI/CD pipelines and do GitOps.
Common CI/CD pipelines include GitHub actions, GitLabs runners, and Azure DevOps. Other less often used are GCP CodeBuild and AWS CodePipeline.

The scenario we are looking at: [M25 Platform Team](https://glowing-guacamole-8korqmy.pages.github.io/dev/meshstack/guides/business_platforms.html) has already built
Cloud Formation template based automation on [GitHub actions](https://github.com/meshcloud/static-website-assets).
The template provisons an S3 Bucket for serving static website assets (a component needed by many frontend teams).

## Challenges

The Cloud Foundation team has identified the following milestones

- make the service discovarable via meshStack
- trigger the existing automation
- provide rich user feedback, e.g. upload instructions, and provide the domain where the hosted content will be available

## Implementation

### Setting Up Building Block Definition

First step towards integrating the existing GitHub Action pipeline, is setting up a Building Block Definition in meshStack.

:::details
The building block simply commits a file into static-website-assets [github repository](https://github.com/likvid-bank/static-website-assets),
and will consequently trigger a GitHub Action workflow that provisions a web hosting enabled AWS S3 bucket.
:::

The definition is created by the M25 Platform team from within their workspace: `${terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName}`.

To set it up:

- create a new definition called `${local.buildingBlockDefinitions.m25-static-website-assets.spec.displayName}` from the "Service Management Area"
- select AWS as supported platform
- use Terraform as Implementation Type (Once per tenant)
- complete Building Block Definition implementation as [defined](https://likvid-bank.github.io/likvid-cloudfoundation/platforms/github/buildingblocks/file/buildingblock.html)
- test and publish

### Application Team Orders an Instance

Application team has the following workspace, project, and tenant:

```bash
Workspace `${terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.spec.displayName}`
└── Project `${meshstack_project.m25_online_banking_app.spec.display_name}`
    └── Tenant `${meshstack_tenant.m25_online_banking_app.spec.local_id}` (AWS Account ID)
```

Now that M25 platform team has their service published, application team ordered building block: `${meshstack_buildingblock.m25_online_banking_app_docs.spec.display_name}`
through their AWS tenant. This triggered a [GitHub action workflow](https://github.com/meshcloud/static-website-assets/actions) identified
with commit `${meshstack_buildingblock.m25_online_banking_app_docs.spec.combined_inputs.commit_message.value_string}`. When clicking that commit,
A deploy summary will exist that explains further steps to upload files into the bucket.

Users that will have access to the bucket are:

```
${join("\n", split(" ", meshstack_buildingblock.m25_online_banking_app_docs.spec.combined_inputs.content.value_string))}
```

### Provide Building Block Status from external System

Coming Soon! 🚀

EOF
}

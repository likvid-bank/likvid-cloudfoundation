locals {
  guide_gitops = <<EOF
# Integrating Existing Automation and GitOps Pipelines

This guide shows you how you can solve common scenarios for integrating existing automation and orchestration
solutions with meshStack.

## Motivation

Most platform teams start with building automation using Infrastructure as Code technologies like Terraform, Cloud Formation,
ARM Templates or automation scripts (Ansible). To execute these automations, teams often times use CI/CD pipelines and do GitOps.
Common CI/CD pipelines include GitHub actions, GitLabs runners, and Azure DevOps. Other less often used are GCP CodeBuild and AWS CodePipeline.
They also want to provide more detailed information to their users e.g. what the status of each step is or general information to the user
when a step was successfully completed (e.g. login information or IDs).

The scenario we are looking at: [M25 Platform Team](https://likvid-bank.github.io/likvid-cloudfoundation/meshstack/guides/business_platforms.html) has already built
Cloud Formation template based automation on [GitHub actions](https://github.com/likvid-bank/static-website-assets).
The template provisons an S3 Bucket for serving static website assets (a component needed by many frontend teams) and assigns access permissions.

## Challenges

The Cloud Foundation team has identified the following milestones:

- make the service discovarable via meshStack's marketplace
- prevent user mistakes from wrong inputs
- trigger the existing automation to create or delete resources
- provide rich user feedback, e.g. upload instructions, and provide the domain where the hosted content will be available

## Implementation

To implement this use case you need to perform three steps. The first step is to integrate an existing GitHub action pipeline by setting up a Building
Block Definition in meshStack. The action pipeline needs to be extended with additional operations which will post back the status updates
and outputs to meshStack. The last step is to test the newly created Building Block and its Definition and if everything looks good this Definition can be
published to make it available to every user who wants to consume the "status website" service.

### 1. Setting Up a Building Block Definition

:::details
The Building Block triggers an action in the static-website-assets [github repository](https://github.com/likvid-bank/static-website-assets),
which provisions a web hosting enabled AWS S3 bucket.
:::

:::details
It is important that the Building Block Definition is owned by the `${terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName}` workspace. Otherwise the
API Key (which also must be scoped to this workplace) can't update the Building Block Runs.
:::

1. The Definition is created by the M25 Platform team within their workspace: `${terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName}`.
   Create a new Definition called `${local.buildingBlockDefinitions.m25-static-website-assets.spec.displayName}` from the "Service Management Area" of this workspace
2. Select AWS as supported platform
3. Use Terraform as Implementation Type (Once per tenant)
4. Complete the Building Block Definition implementation as [defined](https://likvid-bank.github.io/likvid-cloudfoundation/meshstack.html#github-action-trigger-building-block)

### 2. Setting Up the Github Action Pipeline

We now assume this pipline does already exist in some form (an example is provided [here](https://github.com/meshcloud/static-website-assets)). We provide example an pipline which sets up a S3 bucket and its permission by using the user list coming from a Building Block
input. This prevents user errors from typos. When a Building Block is deleted the pipeline will cleanup the bucket too.
In the repository settings you also need to configure the following environment variables and secret, which the actions can access during their execution:

#### Environment Variables

* `BUILDINGBLOCK_API_CLIENT_ID` and set it to the meshstack API key ID
* `AWS_ACCOUNT_ID` the AWS account into which the S3 buckets are provisioned
* `IDENTITY_STORE_ID` the ID of the identity store which is used to lookup the users which are getting admin permissions on the bucket
* `SSO_INSTANCE_ARN` the ARN of the SSO instance used

#### Secrets

* `BUILDINGBLOCK_API_KEY_SECRET` and fill it with the meshstack API key secret.
* `AWS_ACCESS_KEY_ID` the access key from ID from AWS
* `AWS_SECRET_ACCESS_KEY` the secret of the key from AWS

### Application Team Orders an Instance

Application team has the following workspace, project, and tenant:

```bash
Workspace `${terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.spec.displayName}`
└── Project `${meshstack_project.m25_online_banking_app.spec.display_name}`
    └── Tenant `${meshstack_tenant.m25_online_banking_app.spec.local_id}` (AWS Account ID)
```

Now that M25 platform team has their service published and application team may ordered the website hosting service: `${meshstack_buildingblock.m25_online_banking_app_docs.spec.display_name}`
through their AWS tenants. This triggered a [GitHub action workflow](https://github.com/likvid-bank/static-website-assets/actions). This action extracts the user from the Building Block
Run data which is provided as an input and assigns permissions to all user on the project. Currently only admin users gain admin permissions.
In the "Deploy Resources" workflow in the "Received Building Block Run" step you can see the decoded Building Block Run data for debugging.

### 3. Provide Building Block Status from external System

The status is already automatically reported back by the example GitOps pipeline. This is how the pipeline does it: first need an API Key with the permission to write/update Building Block Run
sources. This API key must be scoped to the repository ${terraform_data.meshobjects_import["workspaces/m25-platform.yml"].output.spec.displayName} (in which the Building Block definition lives).
You then need to fetch an access token from this API key and then you can use the [meshObject API](https://federation.demo.meshcloud.io/docs/index.html#mesh_buildingblockrun) in order
to register steps or report back the current status of those steps. Please keep in mind that this only works when the Building Block is asynchronous.
EOF
}

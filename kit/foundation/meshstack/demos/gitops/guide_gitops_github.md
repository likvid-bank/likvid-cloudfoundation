# Integrating Existing GitHub CI/CD Pipelines

This guide shows platform engineers how to integrate existing automation and GitOps workflows with meshStack using Building Blocks.

## Motivation

Platform teams often have existing Infrastructure as Code automations (Terraform, CloudFormation, ARM Templates) running through CI/CD pipelines in tools like GitHub Actions, GitLab CI, or Azure DevOps. These teams want to:

- Make services discoverable via meshStack's marketplace
- Prevent user input errors
- Trigger existing automation for resource provisioning/deprovisioning
- Provide rich feedback to users (status updates, access information, etc.)

meshStack solves these challenges by integrating existing pipelines as an implementation type for building blocks.

## Example Scenario

The ${md_workspace_m25_platform_team} has built CloudFormation-based automation with a [GitHub Actions workflow](${static_website_assets_repo_url}) that provisions S3 buckets for static website assets, a service needed by marketing departments that need a quick and simple way to host files for campaigns.

## Implementation

This integration requires the following steps:

1. **Create a Building Block Definition** in meshStack that captures user inputs
2. **Setup GitHub Integration settings** in meshStack to trigger GitHub Actions workflows
3. **Extend your GitHub Actions pipeline** to communicate back to meshStack
4. **Test and publish** the Building Block for application team consumption

### 1. Setting Up a Building Block Definition

Create a Building Block Definition that will trigger your existing GitHub Actions workflow.

**Steps:**

1. In the ${md_workspace_m25_platform_team} workspace, navigate to the "Platform Builder"
2. Create a new Building Block Definition called `${buildingBlockDefinitions_m25-static-website-assets_spec_displayName}`.
3. Select "GitHub Actions" as the implementation type
5. When configuring the building block implementation, select a new GitHub Integration and configure it as described in the next section.

### 2. Setting Up the GitHub Integration

1. [Register a GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app) with the following permissions
    - `Actions Read and Write` to trigger workflows
    - `Workflows Read and Write` to manage workflows
    - `Contents Read` to read repository information
2. [Create a key](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/managing-private-keys-for-github-apps)
3. And then configure it to use the `deploy.yml` workflow from the [static-website-assets repository](${static_website_assets_repo_url}/tree/main/.github/workflows/deploy.yml) and the `destroy.yml` workflow for deletions.
4. As inputs add
    - `bucket_name` with source: user input
    - `user_permissions` with source: user permissions

### 3. Extend your GitHub Actions pipeline

Since we want to communicate status back from the pipeline in a form that's easily consumable
by application teams, we need to extend the pipeline.

To do so, we will leverage three GitHub actions published by meshcloud that simplify this process

- [meshcloud/actions-meshstack-auth](https://github.com/meshcloud/actions-meshstack-auth) to authenticate with meshStack using an API key
- [meshcloud/actions-register-source](https://github.com/meshcloud/actions-register-source) to register the steps of our pipeline
- [meshcloud/action-send-status](https://github.com/meshcloud/actions-send-status) to provide status about each step

To use the pipeline, you will also need to setup an API Key in meshStack with the permission to update Building Block Runs.
This can be done by creating a new API Key in the ${md_workspace_m25_platform_team} workspace and assigning it the `Building Block Run` permission.

You can see a full example pipeline at [static-website-assets](${static_website_assets_repo_url}/tree/main/.github/workflows). This pipeline shows three key features

1. Extracts user input from the Building Block Run data
2. Provisions the S3 bucket with user permissions received from meshStack
3. Report pipeline execution status back to meshStack

::tip
These actions utilize the [meshObject API](../../api/index.html#mesh_buildingblockrun) to register steps and report status.
:::


### 4. Test and Publish

Once your Building Block is published, application teams can order the service from the marketplace.
In our demo, the ${md_workspace_m25_online_banking} has an instance of this building block provisioned.

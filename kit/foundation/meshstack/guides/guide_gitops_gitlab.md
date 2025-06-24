# Integrating Existing GitLab CI/CD Pipelines

## Motivation / Business Context

The scenario we are looking at: [M25 Platform Team](./guide_business_platforms.md) has already built
Cloud Formation template based automation on [GitHub actions](https://gitlab.com/likvid-bank/static-website-assets).
GitLab CI/CD provisons an S3 Bucket for serving static website assets (a component needed by many frontend teams) and assigns access permissions.
This guide shows how such existing GitLab CI/CD solutions can be integrated with meshStack to leverage prior investments while benefiting from meshStack's capabilities.

## Challenges

Platform teams like M25 often possess established and valuable CI/CD pipelines for their automation.
A key challenge is to integrate these existing assets into meshStack. This integration should enable a seamless self-service experience for application teams, without necessitating a complete rewrite of the proven automation.
Specific challenges include:

- Triggering external GitLab CI/CD pipelines from meshStack.
- Securely passing necessary parameters (user inputs) to the pipelines.
- Receiving status updates and outputs back from the pipelines into meshStack.
- Ensuring the integration aligns with meshStack's governance model and control mechanisms.

## Implementation Steps

This integration requires three main steps:

1. **Create a building block definition** in meshStack that captures user inputs and triggers a GitLab CI/CD pipeline
2. **Extend your GitLab CI/CD pipeline** to communicate with meshStack
3. **Test and publish** the building block for application team consumption

### 1. Setting Up a Building Block Definition

Create a building block definition that will trigger your existing GitLab CI/CD pipeline with any required user inputs.

1. In the ${md_workspace_m25_platform_team} workspace navigate to the "Platform Builder".
2. Create a new building block definition and select GitLab CI/CD, it should be called `${buildingBlockDefinitions_m25-static-website-assets_spec_displayName}`
3. Type should be "Workspace Building Block" since the S3 buckets that will be managed are independent of any other tenants.
4. Enter GitLab specific configuration
   1. Base URL of the GitLab instance
   2. Pipeline trigger token: found in GitLab under settings - CI/CD
   3. Project ID: found in GitLab under settings - general
   4. Branch or tag name
5. Configure inputs:
   1. `environment`: pipeline jobs run in a specific GitLab environment to allow running in test and productive environments, use a static value of `m25`
   2. `bucket-name`: user input to configure the desired bucket name
6. Configure string outputs:
   1. `bucket_name`: actual bucket name in S3
   2. `website_url`: URL to access the bucket content as a website

### 2. Extending the Existing Pipeline

To use a GitLab CI/CD pipeline as a building block it must communicate with meshStack.
For this purpose meshcloud provides [CI/CD components](https://gitlab.com/explore/catalog/meshcloud/meshstack-integration).

In this scenario we're going to use automatic status updates.
More advanced scenarios can use manual status updates, please refer to the CI/CD component [documentation](https://gitlab.com/meshcloud/meshstack-integration) for more information.

We change the pipeline to include the meshStack integration component.

```yaml
include:
  - component: $CI_SERVER_FQDN/meshcloud/meshstack-integration/building-block-run@0.1.0
```

This will automatically authenticate with meshStack, register the building block run and send a final report including outputs when the pipeline is finished.

We must also provide our GitLab project with an API key in the form of `MESHSTACK_API_KEY` and `MESHSTACK_API_SECRET` CI/CD variables.
Create an API key in the ${md_workspace_m25_platform_team} workspace and assign it permissions to create/update building block runs.

As part of our CI/CD pipeline we also use the meshStack API to retrieve user permissions for the workspace when a building block is provisioned.
We use the user permissions from meshStack to set according permissions in S3.
In order to do this the API key also requires admin permissions to list all users.
These permissions can only be added to the API key via the admin area.

Once the API key is in place the pipeline can also report building block outputs back to meshStack by creating artifacts in a specific directory.
A job writing to a file `bb_output/$CI_JOB_ID/website_url` will result in the file content being reported as an output with the name `website_url` if the file is exported as an artifact.

```yaml
job:
  artifacts:
    paths:
      - bb_output
```

### 3. Test and Publish

Test your new definition by creating a building block in the same workspace.
Make sure to test deletion as well.
Once you're statisified with the results publish it to make it usable by your whole organization.

## Conclusion

By following these steps, platform teams can successfully integrate their existing GitLab CI/CD pipelines with meshStack.
This approach allows them to leverage their current automation investments while providing a standardized and governed self-service experience for consuming these services through meshStack.
Application teams benefit from easy access to established components like static website hosting, provisioned through familiar meshStack building blocks, thereby accelerating their development cycles and ensuring compliance.

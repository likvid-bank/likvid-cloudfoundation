# Importing building blocks from meshStack Hub

This guide shows you how you can accelerate your platform engineering with pre-built building blocks from meshStack Hub.

## Motivation

Platform teams are expected to provide standardized, secure infrastructure quickly and at scale.
However, defining and maintaining these components, such as landing zones, networking, or security baselines, requires
significant effort and specialized knowledge. Building blocks on the meshStack hub offer a community-maintained resource 
for getting started quickly with common platform engineering challenges by leveraging tried and tested building
blocks.

## Implementation Steps

### Story Lane

You can view all steps of this demo story in [StoryLane](https://app.storylane.io/share/hzzabrqbgthk) as well.

### Prerequisites

- You have permissions to manage Building Block Definitions.
  We recommend using the Platform Builder in the ${md_workspace_m25_platform_team} workspace.
- You have credentials that can deploy AWS S3 Buckets. You can find these in Likvid Bank's Bitwarden under `buildingblock/s3-bucket-likvid`.

### Visit meshStack Hub

- Visit [hub.meshcloud.io](https://hub.meshcloud.io) to browse the collection of curated, ready-to-use Terraform modules.
- Locate the [AWS S3 Bucket](https://hub.meshcloud.io/platforms/aws/definitions/aws-s3_bucket). The module includes a description and purpose and a direct import button to meshStack.

### Importing a Building Block Definition

- Choose a module, in this case *AWS S3 Bucket*
- Click the **Import to meshStack** button.
- Enter the URL of your meshStack (if not given already)
- You're redirected to meshPanel and are asked where to import the building block definition.
  Pick the ${md_workspace_m25_platform_team} workspace.
- You will be redirected to the **building block definition** creation page with some pre-populated information

### Finish Creation of the Building Block Defintion

- You can continue the pre-populated form to create the Building Block Definition.
- The inputs will be automatically imported. You only need to fill in the AWS Secret Key and AWS Access Key ID (from Bitwarden)
- Finish the creation wizard

### Finishing up

✅ That's it! You now have a fully working Building Block Definition for an AWS S3 Bucket that can be used by application teams to provision compliant S3 buckets in their projects.

### Conclusion

This demo illustrates how **meshStack Hub** enables fast, compliant infrastructure provisioning by providing **pre-built Terraform modules** that are easily imported as **Building Block Definitions**.
By reducing boilerplate effort and aligning with best practices, teams like Likvid Bank can offer standardized, reusable infrastructure patterns with minimal overhead.

# **Demo Story: Importing Ready-to-Use Infrastructure with meshStack Hub**

This guide shows you how you can accelerate your cloud governance with pre-built building blocks from meshStack Hub

## Motivation

Platform teams are expected to provide standardized, secure infrastructure quickly and at scale.
However, defining and maintaining these components, such as landing zones, networking, or security baselines, requires
significant effort and specialized knowledge. This slows down cloud adoption and introduces risk through inconsistent implementations.

## Challenges

- Defining compliant infrastructure takes time and deep cloud expertise.
- Inconsistencies arise across teams and environments.
- It's unclear how to shape and scope reusable services for application teams.
- There's a lack of curated modules that reflect cloud best practices.

## Implementation Steps

### Prerequisites

- You have permissions to manage Building Block Definitions.
  We recommend using the Platform Builder in the `M25 Platform Team` workspace.
- You have credentials that can deploy AWS S3 Buckets. You can find these in Bitwarden under `buildingblock/s3-bucket-likvid`.

### Visit meshStack Hub

- Visit [hub.meshcloud.io](https://hub.meshcloud.io) to browse the collection of curated, ready-to-use Terraform modules.
- When opened, the module includes a description and purpose and a direct import button to meshStack.

### Importing a Building Block Definition

- Choose a module, in this case *AWS S3 Bucket*
- Click the **Import to meshStack** button.
- Enter the URL of your meshStack (if not given already)
- You're redirected to meshPanel and are asked where to import the building block definition.
  Pick the `M25 Platform Team` workspace.
- You will be redirected to the **building block definition** creation page with some pre-populated information

### Finish Creation of the Building Block Defintion

- You can continue the pre-populated form to create the Building Block Definition.
- The inputs will be automatically imported. You only need to fill in the AWS Secret Key and AWS Access Key ID (from BitWarden)
- Finish the creation wizard

### Finishing up

✅ That's it! You now have a fully working Building Block Definition for an AWS S3 Bucket that can be used by application teams to provision compliant S3 buckets in their projects.

### Conclusion

This demo illustrates how **meshStack Hub** enables fast, compliant infrastructure provisioning by providing **pre-built Terraform modules** that are easily imported as **Building Block Definitions**.
By reducing boilerplate effort and aligning with best practices, teams like Likvid Bank can offer standardized, reusable infrastructure patterns with minimal overhead.

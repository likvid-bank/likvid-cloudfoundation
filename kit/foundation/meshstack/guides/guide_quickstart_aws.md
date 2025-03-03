# Quickstart AWS Buildingblock

M25 platform team wants to start offering AWS services to application teams through meshStack's building blocks functionality. To try it out first, they have decided to start small, and provide a simple S3 bucket to consumers.

They start their journey by checking out [AWS Building Block Quickstart Guide](link-to-docs), and ensure they meet all the listed prerequisites.

## AWS Account

In their workspace `${meshobjects_import_workspaces_m25_platform_yml_output_spec_displayName }`, they created a project named `${meshstack_project_quickstart_aws_spec_display_name}`, with an AWS tenant (Account: `${meshstack_tenant_quickstart_aws_spec_local_id}`) under landing zone `${meshstack_tenant_quickstart_aws_spec_landing_zone_identifier}`. This account will hold all S3 buckets ordered via application teams.

### Service User

In the created AWS account, they create an IAM user with necessary permissions for performing S3 bucket operations, for simplicity, they provide full access to S3 (`s3:*`).

## Terraform code to provision an S3 Bucket

Instead of creating a terraform module from scratch, use the already existing one in [collie-hub](https://github.com/meshcloud/collie-hub/tree/main/kit/aws/buildingblocks/s3_bucket/buildingblock).

## Conclusion

Now that they have all prerequisites ready, they continue following the [AWS Building Block Quickstart Guide](link-to-docs)
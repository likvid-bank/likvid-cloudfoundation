---
name: AWS S3 bucket BB Backend
summary: |
  Deploys a bucket and IAM user to be leveraged during implementation of buildingblocks.
# optional: add additional metadata about implemented security controls
---

# AWS S3 bucket BB Backend

## Introduction
This kit will deploy the following resources:
- S3 bucket
- IAM user
- IAM Policy

## Instruction
Other buildingblock backplane's should be dependant to this module to be able to export the backend configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.users_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.assume_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy.bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation_name"></a> [foundation\_name](#input\_foundation\_name) | included in AWS S3 storage bucket name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_access_id"></a> [aws\_iam\_access\_id](#output\_aws\_iam\_access\_id) | n/a |
| <a name="output_aws_iam_access_key"></a> [aws\_iam\_access\_key](#output\_aws\_iam\_access\_key) | n/a |
| <a name="output_aws_iam_user"></a> [aws\_iam\_user](#output\_aws\_iam\_user) | n/a |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
<!-- END_TF_DOCS -->
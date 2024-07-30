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
| [aws_cloudformation_stack_set.permissions_in_target_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.permissions_in_target_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_iam_access_key.users_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.assume_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy.bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_organizations_policy.deny_create_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.deny_create_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_iam_policy_document.building_block_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_building_block_backend_account_id"></a> [building\_block\_backend\_account\_id](#input\_building\_block\_backend\_account\_id) | The ID of the backend AWS Account | `string` | n/a | yes |
| <a name="input_building_block_backend_account_service_user_name"></a> [building\_block\_backend\_account\_service\_user\_name](#input\_building\_block\_backend\_account\_service\_user\_name) | Name of the IAM user that meshStack will use to manage building block resources | `string` | n/a | yes |
| <a name="input_building_block_backend_bucket_name"></a> [building\_block\_backend\_bucket\_name](#input\_building\_block\_backend\_bucket\_name) | Name of the S3 bucket | `any` | n/a | yes |
| <a name="input_building_block_target_account_access_role_name"></a> [building\_block\_target\_account\_access\_role\_name](#input\_building\_block\_target\_account\_access\_role\_name) | Account access role used by building-block-service. | `string` | `"BuildingBlockServiceRole"` | no |
| <a name="input_building_block_target_ou_ids"></a> [building\_block\_target\_ou\_ids](#input\_building\_block\_target\_ou\_ids) | List of OUs to deploy the building block service role to | `set(string)` | n/a | yes |

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
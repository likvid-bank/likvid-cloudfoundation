---
name: AWS Platform Bootstrap
summary: |
  creates a service user with permissions to deploy the cloud foundation infrastructure.
  This is a "bootstrap" module, which means that it must be manually executed once by an administrator
  to bootstrap the cloudfoundation
compliance:
  - control: cfmm/iam/privileged-access-management
    statement: |
      The deploy user has privileged access to the cloud foundation infrastructure.
      Access to the credentials of this user are carefully controlled via...
---

# AWS Platform Bootstrap

Creates a service user with permissions to deploy the cloud foundation infrastructure.
This is a "bootstrap" module, which means that it must be manually executed once by an administrator
to bootstrap the cloudfoundation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.root_baseline](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/cloudformation_stack) | resource |
| [aws_cloudformation_stack_set.baseline](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.baseline](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_iam_policy.assume_validation_role](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.validation](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.validation_assume_validation_role_in_org](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.validation_read_only](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_identitystore_group.platform_engineers](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.members](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/identitystore_group_membership) | resource |
| [aws_ssoadmin_account_assignment.platform_engineers](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_permission_set.platform_engineers](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.platform_engineers](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.allow_assume_validation_role_from_github](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_assume_validation_role_in_org](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/iam_policy_document) | data source |
| [aws_identitystore_user.platform_engineers](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation"></a> [foundation](#input\_foundation) | name of the foundation | `string` | n/a | yes |
| <a name="input_parent_ou_id"></a> [parent\_ou\_id](#input\_parent\_ou\_id) | Id of the parent OU used for all accounts in this platform | `string` | n/a | yes |
| <a name="input_platform_engineers_group"></a> [platform\_engineers\_group](#input\_platform\_engineers\_group) | n/a | <pre>object({<br>    name    = string<br>    members = set(string)<br>  })</pre> | n/a | yes |
| <a name="input_tf_backend_account_id"></a> [tf\_backend\_account\_id](#input\_tf\_backend\_account\_id) | The id of the management account | `string` | n/a | yes |
| <a name="input_validation_role_name"></a> [validation\_role\_name](#input\_validation\_role\_name) | Name of the validation/audit role to deploy as part of the baseline into every account managed by this platform | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_baseline_cloudformation_template"></a> [baseline\_cloudformation\_template](#output\_baseline\_cloudformation\_template) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_management_account_id"></a> [management\_account\_id](#output\_management\_account\_id) | The id of your AWS Organization's root account |
| <a name="output_tf_backend_account_id"></a> [tf\_backend\_account\_id](#output\_tf\_backend\_account\_id) | The id of the management account |
| <a name="output_validation_iam_role_arn"></a> [validation\_iam\_role\_arn](#output\_validation\_iam\_role\_arn) | ARN of the IAM role that github can assume to validate the cloudfoundation deployment |
<!-- END_TF_DOCS -->

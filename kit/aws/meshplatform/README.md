---
name: AWS meshPlatform Integration
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# AWS meshPlatform Integration

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.65.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_meshplatform"></a> [meshplatform](#module\_meshplatform) | meshcloud/meshplatform/aws | 0.5.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_service_role_name"></a> [automation\_account\_service\_role\_name](#input\_automation\_account\_service\_role\_name) | Name of the custom role in the automation account. See https://docs.meshcloud.io/docs/meshstack.how-to.integrate-meshplatform-aws-manually.html#set-up-aws-account-3-automation | `string` | `"MeshfedAutomationRole"` | no |
| <a name="input_aws_sso_instance_arn"></a> [aws\_sso\_instance\_arn](#input\_aws\_sso\_instance\_arn) | AWS SSO Instance ARN. Needs to be of the form arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxx. Setup instructions https://docs.meshcloud.io/docs/meshstack.aws.sso-setup.html. | `string` | n/a | yes |
| <a name="input_can_close_accounts_with_tags"></a> [can\_close\_accounts\_with\_tags](#input\_can\_close\_accounts\_with\_tags) | Map of tag keys to lists of tag values that restrict account closure. If not set or empty, accounts can be closed without tag-based restrictions. Example: { "Environment" = ["dev", "staging"], "Team" = ["platform"] } | `map(list(string))` | `{}` | no |
| <a name="input_control_tower_enrollment_enabled"></a> [control\_tower\_enrollment\_enabled](#input\_control\_tower\_enrollment\_enabled) | Set to true, to allow meshStack to enroll Accounts via AWS Control Tower for the meshPlatform. | `bool` | `false` | no |
| <a name="input_control_tower_portfolio_id"></a> [control\_tower\_portfolio\_id](#input\_control\_tower\_portfolio\_id) | Must be set for AWS Control Tower | `string` | `""` | no |
| <a name="input_cost_explorer_management_account_service_role_name"></a> [cost\_explorer\_management\_account\_service\_role\_name](#input\_cost\_explorer\_management\_account\_service\_role\_name) | Name of the custom role in the management account used by the cost explorer user. | `string` | `"MeshCostExplorerServiceRole"` | no |
| <a name="input_cost_explorer_meshcloud_account_service_user_name"></a> [cost\_explorer\_meshcloud\_account\_service\_user\_name](#input\_cost\_explorer\_meshcloud\_account\_service\_user\_name) | Name of the user using cost explorer service to collect metering data. | `string` | `"meshcloud-cost-explorer-user"` | no |
| <a name="input_cost_explorer_privileged_external_id"></a> [cost\_explorer\_privileged\_external\_id](#input\_cost\_explorer\_privileged\_external\_id) | Set this variable to a random UUID version 4. The external id is a secondary key to make an AssumeRole API call. | `string` | n/a | yes |
| <a name="input_create_access_keys"></a> [create\_access\_keys](#input\_create\_access\_keys) | Set to false to disable creation of any service account access keys. | `bool` | `true` | no |
| <a name="input_landing_zone_ou_arns"></a> [landing\_zone\_ou\_arns](#input\_landing\_zone\_ou\_arns) | Organizational Unit ARNs that are used in Landing Zones. We recommend to explicitly list the OU ARNs that meshStack should manage. | `list(string)` | `[]` | no |
| <a name="input_management_account_service_role_name"></a> [management\_account\_service\_role\_name](#input\_management\_account\_service\_role\_name) | Name of the custom role in the management account. See https://docs.meshcloud.io/docs/meshstack.how-to.integrate-meshplatform-aws-manually.html#set-up-aws-account-2-management | `string` | `"MeshfedServiceRole"` | no |
| <a name="input_meshcloud_account_service_user_name"></a> [meshcloud\_account\_service\_user\_name](#input\_meshcloud\_account\_service\_user\_name) | Name of the meshfed-service user. This user is responsible for replication. | `string` | `"meshfed-service-user"` | no |
| <a name="input_replicator_privileged_external_id"></a> [replicator\_privileged\_external\_id](#input\_replicator\_privileged\_external\_id) | Set this variable to a random UUID version 4. The external id is a secondary key to make an AssumeRole API call. | `string` | n/a | yes |
| <a name="input_support_root_account_via_aws_sso"></a> [support\_root\_account\_via\_aws\_sso](#input\_support\_root\_account\_via\_aws\_sso) | Set to true to allow meshStack to manage the Organization's AWS Root account's access via AWS SSO. | `bool` | `false` | no |
| <a name="input_workload_identity_federation"></a> [workload\_identity\_federation](#input\_workload\_identity\_federation) | n/a | <pre>object({<br/>    issuer             = string,<br/>    audience           = string,<br/>    thumbprint         = string,<br/>    replicator_subject = string,<br/>    kraken_subject     = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account_id"></a> [automation\_account\_id](#output\_automation\_account\_id) | Automation Account ID |
| <a name="output_cost_explorer_privileged_external_id"></a> [cost\_explorer\_privileged\_external\_id](#output\_cost\_explorer\_privileged\_external\_id) | Cost explorer privileged\_external\_id |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_management_account_id"></a> [management\_account\_id](#output\_management\_account\_id) | Management Account ID |
| <a name="output_meshcloud_account_id"></a> [meshcloud\_account\_id](#output\_meshcloud\_account\_id) | Meshcloud Account ID |
| <a name="output_metering_aws_iam_keys"></a> [metering\_aws\_iam\_keys](#output\_metering\_aws\_iam\_keys) | You can access your credentials when you execute `terraform output kraken_aws_iam_keys` command |
| <a name="output_metering_workload_identity_federation_role"></a> [metering\_workload\_identity\_federation\_role](#output\_metering\_workload\_identity\_federation\_role) | n/a |
| <a name="output_replicator_aws_iam_keys"></a> [replicator\_aws\_iam\_keys](#output\_replicator\_aws\_iam\_keys) | You can access your credentials when you execute `terraform output replicator_aws_iam_keys` command |
| <a name="output_replicator_privileged_external_id"></a> [replicator\_privileged\_external\_id](#output\_replicator\_privileged\_external\_id) | Replicator privileged\_external\_id |
| <a name="output_replicator_workload_identity_federation_role"></a> [replicator\_workload\_identity\_federation\_role](#output\_replicator\_workload\_identity\_federation\_role) | n/a |
<!-- END_TF_DOCS -->
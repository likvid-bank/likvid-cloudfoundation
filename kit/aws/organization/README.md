---
name: AWS Organization Setup
summary: |
  Configures the AWS Organization
compliance:
  - control: cfmm/tenant-management/resource-hierarchy
    statement: Sets up a resource hierarchy separating administrative from customer workloads
---

# AWS Organization Setup

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

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
| [aws_organizations_account.automation](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.management](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.meshstack](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_account) | resource |
| [aws_organizations_account.networking](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_account) | resource |
| [aws_organizations_organizational_unit.landingzones](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.management](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.parent](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_ssoadmin_account_assignment.admin](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_user.users](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/identitystore_user) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/organizations_organization) | data source |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.admin](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | list of emails of admin users | `list(string)` | n/a | yes |
| <a name="input_automation_account_email"></a> [automation\_account\_email](#input\_automation\_account\_email) | root user email for the automation aws account | `string` | n/a | yes |
| <a name="input_management_account_email"></a> [management\_account\_email](#input\_management\_account\_email) | root user email for the management aws account | `string` | n/a | yes |
| <a name="input_meshstack_account_email"></a> [meshstack\_account\_email](#input\_meshstack\_account\_email) | root user email for the meshstack aws account | `string` | n/a | yes |
| <a name="input_network_management_account_email"></a> [network\_management\_account\_email](#input\_network\_management\_account\_email) | root user email for the network management aws account | `string` | n/a | yes |
| <a name="input_parent_ou_name"></a> [parent\_ou\_name](#input\_parent\_ou\_name) | Create a OU of the specified name and treat it as the root of all resources managed as part of this kit.<br/>    This is good for separation, in particular if you don't have exclusive control over the AWS organization because<br/>    it is supporting non-cloudfoundation workloads as well. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account_id"></a> [automation\_account\_id](#output\_automation\_account\_id) | id of the automation account |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_landingzones_ou_arn"></a> [landingzones\_ou\_arn](#output\_landingzones\_ou\_arn) | arn of the landingzones organizational unit |
| <a name="output_landingzones_ou_id"></a> [landingzones\_ou\_id](#output\_landingzones\_ou\_id) | id of the landingzones organizational unit |
| <a name="output_management_account_id"></a> [management\_account\_id](#output\_management\_account\_id) | id of the management account |
| <a name="output_meshstack_account_id"></a> [meshstack\_account\_id](#output\_meshstack\_account\_id) | id of the meshstack account |
| <a name="output_networking_account_id"></a> [networking\_account\_id](#output\_networking\_account\_id) | id of the networking account |
| <a name="output_org_id"></a> [org\_id](#output\_org\_id) | organiztion id |
| <a name="output_org_root_id"></a> [org\_root\_id](#output\_org\_root\_id) | id of the organization's root (AWS currently supports only a single root) |
| <a name="output_parent_ou_id"></a> [parent\_ou\_id](#output\_parent\_ou\_id) | id of the parent organizational unit |
<!-- END_TF_DOCS -->
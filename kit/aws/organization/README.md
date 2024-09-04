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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_organizational_unit.landingzones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_parent_ou_name"></a> [parent\_ou\_name](#input\_parent\_ou\_name) | Create a OU of the specified name and treat it as the root of all resources managed as part of this kit.<br>    This is good for separation, in particular if you don't have exclusive control over the AWS organization because<br>    it is supporting non-cloudfoundation workloads as well. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_landingzones_ou_id"></a> [landingzones\_ou\_id](#output\_landingzones\_ou\_id) | id of the landingzones organizational unit |
| <a name="output_org_id"></a> [org\_id](#output\_org\_id) | organiztion id |
| <a name="output_org_root_id"></a> [org\_root\_id](#output\_org\_root\_id) | id of the organization's root (AWS currently supports only a single root) |
| <a name="output_parent_ou_id"></a> [parent\_ou\_id](#output\_parent\_ou\_id) | id of the parent organizational unit |
<!-- END_TF_DOCS -->
---
name: AWS Cloud Native Landing Zone
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# AWS Cloud Native Landing Zone

The Cloud Native Landing Zone is designed to leverage the cloud-native services provided by AWS. This approach allows for the full utilization of the benefits of AWS services, including scalability, flexibility, and robustness. It is ideal for workloads that are designed to run in the cloud, taking full advantage of the unique capabilities of cloud computing.

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
| [aws_organizations_organizational_unit.cloud_native](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.dev](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.prod](https://registry.terraform.io/providers/hashicorp/aws/5.65.0/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_parent_ou_id"></a> [parent\_ou\_id](#input\_parent\_ou\_id) | id of the parent OU for this landing zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dev_ou_arn"></a> [dev\_ou\_arn](#output\_dev\_ou\_arn) | organizational unit arn for the dev OU |
| <a name="output_dev_ou_id"></a> [dev\_ou\_id](#output\_dev\_ou\_id) | organizational unit id for the dev OU |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_prod_ou_arn"></a> [prod\_ou\_arn](#output\_prod\_ou\_arn) | organizational unit arn for the prod OU |
| <a name="output_prod_ou_id"></a> [prod\_ou\_id](#output\_prod\_ou\_id) | organizational unit id for the prod OU |
<!-- END_TF_DOCS -->

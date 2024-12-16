---
name: IONOS Bootstrap
summary: |
  Sets up IONOS Cloud for further automation
# optional: add additional metadata about implemented security controls
---

# IONOS Bootstrap

Sets up an IONOS API user with admin rights. This user can be used to deploy other modules.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ionoscloud"></a> [ionoscloud](#requirement\_ionoscloud) | = 6.4.10 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ionoscloud_user.api](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/6.4.10/docs/resources/user) | resource |
| [random_password.api](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email"></a> [email](#input\_email) | n/a | `string` | n/a | yes |
| <a name="input_firstname"></a> [firstname](#input\_firstname) | n/a | `string` | n/a | yes |
| <a name="input_lastname"></a> [lastname](#input\_lastname) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_user"></a> [api\_user](#output\_api\_user) | n/a |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
<!-- END_TF_DOCS -->
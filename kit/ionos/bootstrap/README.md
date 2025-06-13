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
| [ionoscloud_user.admin](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/6.4.10/docs/resources/user) | resource |
| [ionoscloud_user.user](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/6.4.10/docs/resources/user) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin"></a> [admin](#input\_admin) | n/a | <pre>list(object({<br/>    email     = string<br/>    firstname = string<br/>    lastname  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | n/a | <pre>list(object({<br/>    email     = string<br/>    firstname = string<br/>    lastname  = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_passwords"></a> [admin\_passwords](#output\_admin\_passwords) | User passwords |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | User passwords |
<!-- END_TF_DOCS -->
---
name: IONOS Cloud Users
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
# optional: add additional metadata about implemented security controls
---

# IONOS Cloud Users

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ionoscloud"></a> [ionoscloud](#requirement\_ionoscloud) | = 6.4.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ionoscloud_user.api_user](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/6.4.10/docs/resources/user) | resource |
| [ionoscloud_user.user](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/6.4.10/docs/resources/user) | resource |
| [random_password.api_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_users"></a> [api\_users](#input\_api\_users) | n/a | <pre>list(object({<br>    email     = string<br>    firstname = string<br>    lastname  = string<br>  }))</pre> | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | n/a | <pre>list(object({<br>    email     = string<br>    firstname = string<br>    lastname  = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_user_passwords"></a> [api\_user\_passwords](#output\_api\_user\_passwords) | User passwords |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | User passwords |
<!-- END_TF_DOCS -->
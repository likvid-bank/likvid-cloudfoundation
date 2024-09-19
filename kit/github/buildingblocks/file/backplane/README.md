---
name: Backplane of GitHub File Building Block
summary: |
  Gets GitHub App details that can be used in github provider config
# optional: add additional metadata about implemented security controls
---

# Backplane of GitHub File Building Block

To apply this, you need to specify a bitwarden config path

e.g.: `export BITWARDENCLI_APPDATA_DIR=~/.config/.bitwarden`

Afterwards:

```bash
bw login --sso # (meshcloud sso identifier: bitwarden.meshcloud.io)
export BW_SESSION=$(bw unlock --raw)

collie foundation deploy <foundation> --platform github --module buildingblocks/file/backplane`
# type your email address you use in bitwarden
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_bitwarden"></a> [bitwarden](#requirement\_bitwarden) | >=0.8.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 5.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [bitwarden_attachment.github_app_pem_file](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest/docs/data-sources/attachment) | data source |
| [bitwarden_item_login.github_app](https://registry.terraform.io/providers/maxlaverse/bitwarden/latest/docs/data-sources/item_login) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_github_app_id_and_installation_id"></a> [github\_app\_id\_and\_installation\_id](#output\_github\_app\_id\_and\_installation\_id) | n/a |
| <a name="output_github_app_pem_file"></a> [github\_app\_pem\_file](#output\_github\_app\_pem\_file) | n/a |
<!-- END_TF_DOCS -->
---
name: AKS meshPlatform
summary: |
  Creates necessary service account in an AKS cluster that enables meshStack to manage it.
# optional: add additional metadata about implemented security controls
---

# AKS meshPlatform

Creates replicator and metering service account for an existing AKS cluster.

> To execute this module, connect to the AKS cluster: `az aks get-credentials --resource-group aks-rg --name aks --subscription 7490f509-073d-42cd-a720-a7f599a3fd0b`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_meshplatform"></a> [meshplatform](#module\_meshplatform) | git::https://github.com/meshcloud/terraform-aks-meshplatform.git | 91ee5a74ff2101f1ac021167ec628a66d4b09352 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_password"></a> [create\_password](#input\_create\_password) | n/a | `bool` | `true` | no |
| <a name="input_metering_additional_rules"></a> [metering\_additional\_rules](#input\_metering\_additional\_rules) | n/a | <pre>list(object({<br>    api_groups        = list(string)<br>    resources         = list(string)<br>    verbs             = list(string)<br>    resource_names    = optional(list(string))<br>    non_resource_urls = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_metering_enabled"></a> [metering\_enabled](#input\_metering\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_replicator_additional_rules"></a> [replicator\_additional\_rules](#input\_replicator\_additional\_rules) | n/a | <pre>list(object({<br>    api_groups        = list(string)<br>    resources         = list(string)<br>    verbs             = list(string)<br>    resource_names    = optional(list(string))<br>    non_resource_urls = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_replicator_enabled"></a> [replicator\_enabled](#input\_replicator\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | n/a | `string` | n/a | yes |
| <a name="input_service_principal_name"></a> [service\_principal\_name](#input\_service\_principal\_name) | n/a | `string` | n/a | yes |
| <a name="input_workload_identity_federation"></a> [workload\_identity\_federation](#input\_workload\_identity\_federation) | Enable workload identity federation instead of using a password by providing these additional settings. Usually you should receive the required settings when attempting to configure a platform with workload identity federation in meshStack. | `object({ issuer = string, replicator_subject = string })` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_metering_token"></a> [metering\_token](#output\_metering\_token) | # METERING |
| <a name="output_replicator_service_principal"></a> [replicator\_service\_principal](#output\_replicator\_service\_principal) | Replicator Service Principal. |
| <a name="output_replicator_service_principal_password"></a> [replicator\_service\_principal\_password](#output\_replicator\_service\_principal\_password) | Password for Replicator Service Principal. |
| <a name="output_replicator_token"></a> [replicator\_token](#output\_replicator\_token) | n/a |
<!-- END_TF_DOCS -->
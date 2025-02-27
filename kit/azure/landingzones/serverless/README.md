---
name: Azure Landing Zone "Serverless"
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
compliance:
- control: cfmm/security-and-compliance/service-and-location-restrictions
  statement: |
    Restricts the list of permitted Azure services in relation to Serverless.
---

# Azure Landing Zone "Serverless"

This kit provides a Terraform configuration for setting up Azure Management Groups for dedicated Management Group and policy for Serverless Landingzones.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_policy_serverless"></a> [policy\_serverless](#module\_policy\_serverless) | github.com/meshcloud/collie-hub//kit/azure/util/azure-policies | ef06c8d |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.serverless](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/resources/management_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure location where this policy assignment should exist, required when an Identity is assigned. | `string` | `"germanywestcentral"` | no |
| <a name="input_lz-serverless"></a> [lz-serverless](#input\_lz-serverless) | n/a | `string` | `"serverless"` | no |
| <a name="input_parent_management_group_id"></a> [parent\_management\_group\_id](#input\_parent\_management\_group\_id) | The tenant management group of your cloud foundation | `string` | `"lv-foundation"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_management_id"></a> [management\_id](#output\_management\_id) | n/a |
<!-- END_TF_DOCS -->

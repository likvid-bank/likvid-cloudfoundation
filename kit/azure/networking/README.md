---
name: Azure Networking
summary: |
  Starting point for a hub and spoke networking model.
---

# Azure Networking

This is a simple hub example. It deploys a hub vnet to demonstrate vnet peering with spokes.
There is no connection to an on-premise environment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.41.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group_subscription_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_subscription_association) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.cloudfoundation_tfdeploy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloudfoundation_tfdeploy_lz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor_lz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.cloudfoundation_tfdeploy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.cloudfoundation_tfdeploy_lz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | n/a | `list(string)` | n/a | yes |
| <a name="input_cloudfoundation_deploy_principal_id"></a> [cloudfoundation\_deploy\_principal\_id](#input\_cloudfoundation\_deploy\_principal\_id) | n/a | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `any` | n/a | yes |
| <a name="input_parent_management_group_id"></a> [parent\_management\_group\_id](#input\_parent\_management\_group\_id) | n/a | `any` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | id of the management group that you want to manage spokes in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_hub_location"></a> [hub\_location](#output\_hub\_location) | Location of hub vnet |
| <a name="output_hub_rg"></a> [hub\_rg](#output\_hub\_rg) | Resource Group of hub vnet |
| <a name="output_hub_subscription"></a> [hub\_subscription](#output\_hub\_subscription) | Subscription of hub vnet |
| <a name="output_hub_vnet"></a> [hub\_vnet](#output\_hub\_vnet) | Name of hub vnet |
<!-- END_TF_DOCS -->
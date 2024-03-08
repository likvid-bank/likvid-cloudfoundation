---
name: Azure Building Block - Subscription Budget Alert
summary: |
  Building block module for adding a simple monthly budget alert to a subscription.
---

# Azure Subscription Budget Alert

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

## Permissions

This is a very simple building block, which means we let the SPN have access to deploy budget alerts
across all subscriptions underneath a management group (typically the top-level management group for landing zones).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.46.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.buildingblock](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.buildingblock](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.buildingblock](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_resource_group.tfstates](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.buildingblock_deploy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.terraform_state](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.buildingblock_deploy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_storage_account.tfstates](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.tfstates](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_string.resource_code](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_rotating.key_rotation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_group.bb_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bb_admins_group_id"></a> [bb\_admins\_group\_id](#input\_bb\_admins\_group\_id) | Id of an AAD group for platform engineers working with the buidling block | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location for deploying the building block terraform state storage account | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | name of the building block, used for naming resources | `string` | `"budget-alert"` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope where the building block should be deployable, typically the parent of all Landing Zones. | `string` | n/a | yes |
| <a name="input_service_principal_name"></a> [service\_principal\_name](#input\_service\_principal\_name) | name of the Service Principal used to perform all deployments of this building block | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_tf"></a> [config\_tf](#output\_config\_tf) | Generates a config.tf that can be dropped into meshStack's BuildingBlockDefinition as an encrypted file input to configure this building block. |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
<!-- END_TF_DOCS -->
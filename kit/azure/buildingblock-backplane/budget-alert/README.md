---
name: Azure budget-alert buildingblock backplane
summary: |
This module will generate  backend and a provider configuration to be leverage during the creationg of the respective buildingblock definition.
---

# Azure budget-alert buildingblock backplane

## Introduction
This kit will generate the backplane configuration required to deploy the following buildingblock:
**azure/monitoring/budget-alert**

## Instruction
Please add backend and provider output of this module as an input for your buildingblock definition.

Note: If the buildingblock module already includes provider and/or backend configuration, you should either remove them or ensure that these variables are passed with higher priority.

Note: Please make sure there wouldn't be a duplication in the file names.

## Dependency:
azure/buildingblock-backplane/storage-account

## Output:
To generate the following files please set the **generate_local_files** value to "1".

Default Path: "${foundation}/${platform}/buildingblock-backplane/monitoring/budget-alert/outputs/

- generated-backend.tf
- generated-provider.tf

**Note**: To export the outputs as file, please uncomment the file resource on the main-backend.tf and main-provider.tf
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.45.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.79.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.building_blocks](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.building_blocks_application_pw](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.building_blocks_spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.backend_storage_read](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.building_blocks_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.custom_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.role_budget_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [local_file.backend](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.provider](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [time_rotating.building_blocks_secret_rotation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_tf_config_path"></a> [backend\_tf\_config\_path](#input\_backend\_tf\_config\_path) | n/a | `string` | n/a | yes |
| <a name="input_container_id"></a> [container\_id](#input\_container\_id) | Id of the tfstate's container | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Container name holding the tfstates | `string` | n/a | yes |
| <a name="input_deployment_scope"></a> [deployment\_scope](#input\_deployment\_scope) | The scope where this service principal have access on. It is recommended to use the meshcloud's management group, so the buildingblock can be re-used within any projects | `string` | n/a | yes |
| <a name="input_generate_local_files"></a> [generate\_local\_files](#input\_generate\_local\_files) | Please Enter '1' in order to generate the outputs as file. Default is '0' | `number` | `"0"` | no |
| <a name="input_provider_tf_config_path"></a> [provider\_tf\_config\_path](#input\_provider\_tf\_config\_path) | n/a | `string` | n/a | yes |
| <a name="input_sta_name"></a> [sta\_name](#input\_sta\_name) | Storage account name | `string` | n/a | yes |
| <a name="input_sta_rg_id"></a> [sta\_rg\_id](#input\_sta\_rg\_id) | Id of the storage account's resource group | `string` | n/a | yes |
| <a name="input_sta_rg_name"></a> [sta\_rg\_name](#input\_sta\_rg\_name) | Resource group name holding the storage account | `string` | n/a | yes |
| <a name="input_sta_subscription_id"></a> [sta\_subscription\_id](#input\_sta\_subscription\_id) | Id of the subscription holding the backend's storage account | `string` | n/a | yes |
| <a name="input_storage_account_resource_id"></a> [storage\_account\_resource\_id](#input\_storage\_account\_resource\_id) | This is the ID of the storage account resource and it retrievable via panel. It is in the format of '/subscription/<sub\_id>/resourcegroups/<rg\_name>/... | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id of the storage account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_tf"></a> [backend\_tf](#output\_backend\_tf) | Generates a config.tf that can be dropped into meshStack's BuildingBlock Definition as an encrypted file input to configure this building block. |
| <a name="output_documentation_md"></a> [documentation\_md](#output\_documentation\_md) | n/a |
| <a name="output_provider_tf"></a> [provider\_tf](#output\_provider\_tf) | Generates a config.tf that can be dropped into meshStack's BuildingBlockDefinition as an encrypted file input to configure this building block. |
<!-- END_TF_DOCS -->
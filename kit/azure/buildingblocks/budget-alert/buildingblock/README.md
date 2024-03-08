Deploys a simple monthly budget alert for a subscription. The alert will notify via email of forecasted
and actual budget overruns.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_consumption_budget_subscription.subscription_budget](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription) | resource |
| [azurerm_resource_provider_registration.providers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration) | resource |
| [azurerm_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actual_threshold_percent"></a> [actual\_threshold\_percent](#input\_actual\_threshold\_percent) | The precise percentage of the monthly budget at which you wish to activate the alert upon reaching. E.g. '15' for 15% or '120' for 120% | `number` | `80` | no |
| <a name="input_budget_name"></a> [budget\_name](#input\_budget\_name) | Name of the budget alert rule | `string` | `"budget_alert"` | no |
| <a name="input_contact_emails"></a> [contact\_emails](#input\_contact\_emails) | List of emails of the users who should receive the Budget alert. e.g. ['foo@example.com', 'bar@example.com'] | `list(string)` | n/a | yes |
| <a name="input_forcasted_threshold_percent"></a> [forcasted\_threshold\_percent](#input\_forcasted\_threshold\_percent) | The forcasted percentage of the monthly budget at which you wish to activate the alert upon reaching. E.g. '15' for 15% or '120' for 120% | `number` | `100` | no |
| <a name="input_monthly_budget_amount"></a> [monthly\_budget\_amount](#input\_monthly\_budget\_amount) | Set the monthly budget for this subscription in the billing currency. | `number` | `100` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The ID of the subscription at which you want to assign the budget | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_amount"></a> [budget\_amount](#output\_budget\_amount) | n/a |
<!-- END_TF_DOCS -->
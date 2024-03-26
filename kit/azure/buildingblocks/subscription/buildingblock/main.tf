data "azurerm_subscription" "current" {
}

// set name, tags
resource "azurerm_subscription" "this" {
  subscription_id   = data.azurerm_subscription.current.subscription_id
  subscription_name = var.subscription_name
}

// control placement in the LZ hierarchy
resource "azurerm_management_group_subscription_association" "lz" {
  management_group_id = var.parent_management_group
  subscription_id     = data.azurerm_subscription.current.id
}

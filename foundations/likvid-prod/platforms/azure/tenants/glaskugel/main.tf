module "subscription" {
  source = "git::https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/subscription/buildingblock?ref=v0.5.3"

  subscription_name       = "glaskugel"
  parent_management_group = var.corp_management_group
}

data "azurerm_subscription" "current" {}

module "budget_alert" {
  source = "git::https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/budget-alert/buildingblock?ref=v0.5.3"

  subscription_id       = data.azurerm_subscription.current.subscription_id
  contact_emails        = "fnowarre@meshcloud.io,jrudolph@meshcloud.io"
  monthly_budget_amount = 10
}


module "connectivity" {
  source = "git::https://github.com/meshcloud/collie-hub.git//kit/azure/buildingblocks/connectivity/buildingblock?ref=v0.5.3"

  providers = {
    azurerm.spoke = azurerm
    azurerm.hub   = azurerm.hub
  }

  subscription_id          = data.azurerm_subscription.current.subscription_id
  location                 = "germanywestcentral"
  hub_rg                   = var.hub_rg
  hub_vnet                 = var.hub_vnet
  spoke_owner_principal_id = var.spoke_owner_principal_id

  name          = "glaskugel"
  address_space = "10.1.0.0/24"
}

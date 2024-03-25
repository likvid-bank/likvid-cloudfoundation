module "subscription" {
  source = "../../../../../../../../../kit/azure/buildingblocks/subscription/buildingblock"

  subscription_name       = "glaskugel"
  parent_management_group = "likvid-corp"
}

data "azurerm_subscription" "current" {}

module "budget_alert" {
  source = "../../../../../../../../../kit/azure/buildingblocks/budget-alert/buildingblock"

  subscription_id       = data.azurerm_subscription.current.subscription_id
  contact_emails        = "fnowarre@meshcloud.io,jrudolph@meshcloud.io"
  monthly_budget_amount = 10
}


module "connectivity" {
  source = "../../../../../../../../../kit/azure/buildingblocks/connectivity/buildingblock"

  providers = {
    azurerm.spoke = azurerm
    azurerm.hub   = azurerm.hub
  }

  subscription_id = data.azurerm_subscription.current.subscription_id
  location        = "germanywestcentral"
  hub_rg          = var.hub_rg
  hub_vnet        = var.hub_vnet

  name          = "glaskugel"
  address_space = "10.1.0.0/24"
}

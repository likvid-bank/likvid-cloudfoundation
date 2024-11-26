module "subscription" {
  source = "../../../../../../../../../kit/azure/buildingblocks/subscription/buildingblock"

  subscription_name       = "glaskugel-2"
  parent_management_group = var.corp_management_group
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

  subscription_id          = data.azurerm_subscription.current.subscription_id
  location                 = "germanywestcentral"
  hub_rg                   = var.hub_rg
  hub_vnet                 = var.hub_vnet
  spoke_owner_principal_id = var.spoke_owner_principal_id

  name          = "glaskugel2"
  address_space = "10.2.1.0/24"
}

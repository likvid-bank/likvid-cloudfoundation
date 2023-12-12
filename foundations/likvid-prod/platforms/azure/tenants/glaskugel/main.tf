module "subscription" {
  source = "../../../../../../../../../kit/azure/buildingblocks/subscription"

  subscription_name       = "glaskugel"
  parent_management_group = "likvid-corp"
}

module "connectivity" {

  providers = {
    azurerm.spoke = azurerm
    azurerm.hub   = azurerm.hub
  }

  source   = "../../../../../../../../../kit/azure/buildingblocks/connectivity"
  location = "germanywestcentral"
  hub_rg   = "hub-vnet-rg"
  hub_vnet = "hub-vnet"

  name          = "glaskugel"
  address_space = ["10.1.0.0/24"]
}


module "subscription" {
  source = "github.com/likvid-bank/likvid-cloudfoundation/kit/azure/buildingblocks/subscription"
  # Use local sources for testing
  # source = "../../../../../../../../../kit/azure/buildingblocks/subscription"

  subscription_name       = "glaskugel"
  parent_management_group = "likvid-corp"
}

module "connectivity" {
  source   = "github.com/likvid-bank/likvid-cloudfoundation/kit/azure/buildingblocks/connectivity"
  # Use local sources for testing
  # source   = "../../../../../../../../../kit/azure/buildingblocks/connectivity"

  providers = {
    azurerm.spoke = azurerm
    azurerm.hub   = azurerm.hub
  }

  location = "germanywestcentral"
  hub_rg   = "hub-vnet-rg"
  hub_vnet = "hub-vnet"

  name          = "glaskugel"
  address_space = ["10.1.0.0/24"]
}


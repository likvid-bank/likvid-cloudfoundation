module "subscription" {
  source = "../../../../../../../../../kit/azure/buildingblocks/subscription"

  subscription_name       = "glaskugel"
  parent_management_group = "likvid-corp"
}

module "connectivity" {
  source = "../../../../../../../../../kit/azure/buildingblocks/connectivity"
}

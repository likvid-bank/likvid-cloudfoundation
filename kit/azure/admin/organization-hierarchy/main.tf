module "billing_admins" {
  source        = "./billing-admins"
  aad_tenant_id = var.aad_tenant_id
  billing_users = var.billing_users
}

data "azurerm_management_group" "root" {
  name = var.aad_tenant_id
}

resource "azurerm_management_group" "platform" {
  name                       = var.platform_management_group_name
  parent_management_group_id = data.azurerm_management_group.root.id
}

resource "azurerm_management_group" "admin" {
  name                       = "admin"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}


resource "azurerm_management_group" "landingzones" {
  name                       = "landingzones"
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}



data "azurerm_management_group" "root" {
  name = var.aad_tenant_id
}

resource "azurerm_management_group" "platform" {
  name                       = var.platform_management_group_name
  parent_management_group_id = data.azurerm_management_group.root.id
}

resource "azurerm_management_group" "prod" {
  name                       = "prod"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "dev" {
  name                       = "dev"
  parent_management_group_id = azurerm_management_group.platform.id
}
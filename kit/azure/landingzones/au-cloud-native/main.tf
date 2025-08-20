resource "azurerm_management_group" "au-cloudnative" {
  display_name               = var.name
  parent_management_group_id = var.parent_management_group_id
}

resource "azurerm_management_group" "container_platform" {
  display_name               = var.lz-container-platform
  parent_management_group_id = var.parent_management_group_id
}

module "policy_container_platform" {
  source = "github.com/meshcloud/collie-hub//kit/azure/util/azure-policies?ref=2f2ab85c3c9530df416bb427c711979fbb7c12d6"

  policy_path         = "${path.module}/lib"
  management_group_id = azurerm_management_group.container_platform.id
  location            = var.location

  template_file_variables = {
    default_location          = "${var.location}"
    current_scope_resource_id = azurerm_management_group.container_platform.id
  }
}

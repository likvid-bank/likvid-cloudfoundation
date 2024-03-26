locals {
  # we use the first value of var.locations as the primary location where the policy lives.
  default_location = var.locations[0]
}

# location restriction
data "azurerm_management_group" "parent" {
  display_name = var.parentManagementGroup
}

module "policy_root" {
  source = "github.com/meshcloud/collie-hub//kit/azure/util/azure-policies?ref=da8dd49"

  policy_path         = "${path.module}/lib"
  management_group_id = data.azurerm_management_group.parent.id
  location            = local.default_location

  template_file_variables = {
    allowed_locations_json    = jsonencode(var.locations)
    default_location          = local.default_location
    current_scope_resource_id = data.azurerm_management_group.parent.id
    root_scope_resource_id    = data.azurerm_management_group.parent.id
  }
}

resource "azurerm_management_group" "landingzones" {
  display_name               = var.landingzones
  parent_management_group_id = data.azurerm_management_group.parent.id
}

resource "azurerm_management_group" "platform" {
  display_name               = var.platform
  parent_management_group_id = data.azurerm_management_group.parent.id
}

resource "azurerm_management_group" "connectivity" {
  display_name               = var.connectivity
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name               = var.identity
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  display_name               = var.management
  parent_management_group_id = azurerm_management_group.platform.id
}

# moves the management subscription into the new organization hierarchy
data "azurerm_subscription" "current" {
}


resource "null_resource" "management_subscription_name" {
  # note: we assume we are running azure CLI with CLI authentication, which should hopefully also work in CI
  provisioner "local-exec" {
    when    = create
    command = "az account subscription rename --id ${data.azurerm_subscription.current.subscription_id} --name ${var.management_subscription_name}"
  }
}

resource "azurerm_management_group_subscription_association" "management" {
  management_group_id = azurerm_management_group.management.id
  subscription_id     = data.azurerm_subscription.current.id
}

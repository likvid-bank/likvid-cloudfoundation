data "azurerm_subscription" "current" {
}

#TODO setting the name doesn't work. Azure says alias is already in use. Importing fails because I can't figure out which alias to use for that.
# resource "azurerm_subscription" "networking" {
#   subscription_id   = data.azurerm_subscription.current.subscription_id
#   subscription_name = "hub"
# }

resource "azurerm_management_group_subscription_association" "this" {
  subscription_id = data.azurerm_subscription.current.id
  management_group_id = var.parent_management_group_id
}

# Permissions for deploy user
resource "azurerm_role_definition" "cloudfoundation_tfdeploy" {
  name  = "hub_networking" #TODO definition names are unique per tenant. make it configurable
  scope = data.azurerm_subscription.current.id
  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
    ]
  }
}

resource "azurerm_role_assignment" "cloudfoundation_tfdeploy" {
  principal_id       = var.cloudfoundation_deploy_principal_id
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.cloudfoundation_tfdeploy.role_definition_resource_id
}

resource "azurerm_role_assignment" "network_contributor" {
  principal_id         = var.cloudfoundation_deploy_principal_id
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
}

# Resources
resource "azurerm_resource_group" "this" {
  name     = "hub-vnet-rg"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "hub-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
}

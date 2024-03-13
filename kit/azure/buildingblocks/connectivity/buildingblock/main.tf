#
# 1. Gain access to the subscription for deploying a resource group
#
resource "azurerm_role_assignment" "spoke_subscription" {
  provider = azurerm.spoke

  role_definition_id = local.access_role_definition_id
  principal_id       = local.principal_id
  scope              = azurerm_resource_group.spoke_rg.id
}
#
# 2. deploy the resource group and assign permission to deploy network
#

resource "azurerm_resource_group" "spoke_rg" {
  provider = azurerm.spoke

  name     = "connectivity-rg"
  location = var.location
}

resource "azurerm_role_assignment" "spoke_rg" {
  provider = azurerm.spoke

  role_definition_name = "Network Contributor"
  principal_id         = local.principal_id
  scope                = azurerm_resource_group.spoke_rg.id
}

#
# 3. deploy the actual network
#
resource "azurerm_virtual_network" "spoke_vnet" {
  provider   = azurerm.spoke
  depends_on = [azurerm_role_assignment.spoke_rg]

  name                = "${var.name}-vnet"
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  address_space       = var.address_space
}

#
# 4. establish the peering
#

data "azurerm_resource_group" "hub_rg" {
  provider = azurerm.hub
  name     = var.hub_rg
}

data "azurerm_virtual_network" "hub_vnet" {
  provider            = azurerm.hub
  name                = var.hub_vnet
  resource_group_name = data.azurerm_resource_group.hub_rg.name
}

resource "azurerm_virtual_network_peering" "spoke_hub_peer" {
  provider                  = azurerm.spoke
  name                      = var.name
  resource_group_name       = azurerm_resource_group.spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id

  depends_on = [azurerm_virtual_network.spoke_vnet]
}


resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
  provider = azurerm.hub

  name                      = var.name
  resource_group_name       = data.azurerm_resource_group.hub_rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id

  depends_on = [azurerm_virtual_network.spoke_vnet]
}


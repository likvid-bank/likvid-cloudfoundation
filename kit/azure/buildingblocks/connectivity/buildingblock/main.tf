#
# 1. deploy the resource group and assign permission to deploy network
#
data "azurerm_client_config" "spoke" {
  provider = azurerm.spoke
}

resource "azurerm_resource_group" "spoke_rg" {
  provider = azurerm.spoke

  name     = "connectivity"
  location = var.location
}

resource "azurerm_role_assignment" "spoke_rg" {
  provider = azurerm.spoke
  lifecycle {
    # the owner assignment is required because it contains the permission required to destroy the RG
    # it will be gone with the RG anyway
    prevent_destroy = true
  }

  role_definition_name = "Owner"
  principal_id         = data.azurerm_client_config.spoke.object_id
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
  depends_on = [azurerm_virtual_network.spoke_vnet]

  name                      = var.name
  resource_group_name       = azurerm_resource_group.spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id

}


resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
  provider = azurerm.hub
  depends_on = [azurerm_virtual_network.spoke_vnet]

  name                      = var.name
  resource_group_name       = data.azurerm_resource_group.hub_rg.name
  virtual_network_name      = data.azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id

}


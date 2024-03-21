run "verify" {
  variables {
    name          = "terraform-test"
    address_space = ["10.123.123.0/24"]
  }

  assert {
    condition     = azurerm_virtual_network.spoke_vnet.name == "terraform-test-vnet"
    error_message = "invalid vnet name, actual ${azurerm_virtual_network.spoke_vnet.name}"
  }

  assert {
    # jsonencode to work around terraform type limitations
    condition     = jsonencode(azurerm_virtual_network.spoke_vnet.address_space) == jsonencode(["10.123.123.0/24"])
    error_message = "invalid address space, actual: ${jsonencode(azurerm_virtual_network.spoke_vnet.address_space)}"
  }
}


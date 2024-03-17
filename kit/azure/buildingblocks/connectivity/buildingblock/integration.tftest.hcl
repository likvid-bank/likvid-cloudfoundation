run "verify" {
  variables {
    name          = "terraform-test"
    address_space = ["10.123.123.0/24"]
  }

  assert {
    condition     = spoke_hub_peer.spoke_vnet.name == "terraform-test-vnet"
    error_message = "invalid vnet name"
  }

  assert {
    condition     = spoke_hub_peer.spoke_vnet.address_space == ["10.123.123.0/24"]
    error_message = "invalid address space, actual: ${spoke_hub_peer.spoke_vnet.address_space}"
  }
}
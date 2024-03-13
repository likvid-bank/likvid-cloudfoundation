run "verify" {
  variables {
    name          = "terraform-test"
    address_space = ["10.123.123.0/24"]
  }

  assert {
    condition     = azurerm_role_assignment.spoke_subscription.principal_id != null
    error_message = "all good"
  }
}
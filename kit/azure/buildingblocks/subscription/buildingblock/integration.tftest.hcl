# terraform test is cool because it does the apply and destroy lifecycle
# what it doesn't test though is the backend storage. if we want to test that, we need to that via terragrunt

run "verify" {
  variables {
    subscription_name       = "likvid-prod-buildingblock-test"
    parent_management_group = "likvid-landingzones"
  }

  # we only test terraform plan here - it's unfortunately very slow to execute the test otherwise and the azurerm
  # provider likes to complain if alias and management group association already exist
  command = plan

  assert {
    condition = (
      data.azurerm_management_group.lz.display_name == "likvid-landingzones"
      && azurerm_management_group_subscription_association.lz.management_group_id == data.azurerm_management_group.lz.id
    )
    error_message = "did not create correct management group association"
  }

  assert {
    condition     = azurerm_subscription.this.subscription_name == "likvid-prod-buildingblock-test"
    error_message = "did not apply correct subscription name"
  }
}
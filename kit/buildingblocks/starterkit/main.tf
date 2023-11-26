# configure our logging subscription
data "azurerm_subscription" "current" {
}

resource "github_repository" "staticwebsite_template" {
  name        = "starterkit-template-azure-static-website"
  is_template = true
}

# unfortunately we can't set up the app via terraform right now, so we need to manually set this up
# and keep the data here in locals as a handover interface
locals {
  github_app_id = "654209"
  github_app_installation_id = "44437049"
}
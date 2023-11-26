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
  github_org = "likvid-bank"
}

# set up an SPN for the BB execution

data "azuread_group" "project_admins" {
  # note: this group is managed via meshStack
  display_name = "devopstoolchain.buildingblocks-prod-admin"
}

resource "azuread_application" "starterkit" {
  display_name = "devops-toolchain-starterkit-buildingblock"
  description = "This SPN is used by the Likvid Bank DevOps Toolchain team to automate starterkit buildingblocks"
  owners       = data.azuread_group.project_admins.members
}

resource "azuread_service_principal" "starterkit" {
  client_id                    = azuread_application.starterkit.client_id
  app_role_assignment_required = false
  owners                       = data.azuread_group.project_admins.members
}


# note this rotation technique requires the terraform to be run regularly
resource "time_rotating" "key_rotation" {
  rotation_days = 365
}

resource "azuread_service_principal_password" "starterkit" {
  service_principal_id = azuread_service_principal.starterkit.id
  rotate_when_changed = {
    rotation = time_rotating.key_rotation.id
  }
}

# grant access to the terraform state
moved {
    from = azurerm_role_assignment.tfstates_engineers
    to = azurerm_role_assignment.terraform_state
}

resource "azurerm_role_assignment" "terraform_state" {
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.starterkit.object_id
  scope                = azurerm_storage_container.tfstates.resource_manager_id
}

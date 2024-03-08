# set up an SPN for the BB execution

data "azuread_group" "bb_admins" {
  # note: this group is managed via meshStack
  object_id = var.bb_admins_group_id
}

resource "azuread_application" "buildingblock" {
  display_name = var.service_principal_name
  description  = "This SPN is used by the Likvid Bank Cloud Foundation team to automate budget alert building blocks"
  owners       = data.azuread_group.bb_admins.members
}

resource "azuread_service_principal" "buildingblock" {
  client_id                    = azuread_application.buildingblock.client_id
  app_role_assignment_required = false
  owners                       = data.azuread_group.bb_admins.members
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# note this rotation technique requires the terraform to be run regularly
resource "time_rotating" "key_rotation" {
  rotation_days = 365
}

resource "azuread_service_principal_password" "buildingblock" {
  service_principal_id = azuread_service_principal.buildingblock.id
  rotate_when_changed = {
    rotation = time_rotating.key_rotation.id
  }
}
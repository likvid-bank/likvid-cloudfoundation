resource "azuread_group" "platform_engineers" {
  display_name     = var.platform_engineers_group
  description      = "Privileged Cloud Foundation group. Members have full access to deploy cloud foundation infrastructure and landing zones."
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = toset(data.azuread_users.platform_engineers_members.object_ids)
}

# # we build this role as a composite of the permissions of some built-in Azure roles
# locals {
#   platform_browser_roles = toset([
#     # not sure if these other groups really add to it, after all reader is just a "*/"" read permission
#     # but in the future 
#     "Reader",
#     "Cost Management Reader",
#     "Management Group Reader"
#   ])
# }

# data "azurerm_role_definition" "platform_browser_roles" {
#   for_each = local.platform_browser_roles
#   name     = each.key
# }

# locals {
#   platform_browser_permissions = {
#     actions = toset(
#       flatten(
#         [for k, v in data.azurerm_role_definition.platform_browser_roles : v.permissions[0].actions]
#       )
#     )
#     not_actions = toset(
#       flatten(
#         [for k, v in data.azurerm_role_definition.platform_browser_roles : v.permissions[0].not_actions]
#       )
#     )
#     data_actions = toset(
#       flatten(
#         [for k, v in data.azurerm_role_definition.platform_browser_roles : v.permissions[0].data_actions]
#       )
#     )
#     not_data_actions = toset(
#       flatten(
#         [for k, v in data.azurerm_role_definition.platform_browser_roles : v.permissions[0].not_data_actions]
#       )
#     )
#   }
# }

# resource "azurerm_role_definition" "foundation_platform_browser" {
#   scope             = azurerm_management_group.platform.id
#   assignable_scopes = [azurerm_management_group.platform.id]
#   name              = "foundation_platform_browser"
#   description       = "A role for cloud foundation operators to browse platform-level resource hierarchy, org and IAM policy."

#   permissions {
#     actions          = local.platform_browser_permissions.actions
#     not_actions      = local.platform_browser_permissions.not_actions
#     data_actions     = local.platform_browser_permissions.data_actions
#     not_data_actions = local.platform_browser_permissions.not_data_actions
#   }
# }


# data "azuread_users" "foundation_browser_members" {
#   # unfortunately mail_nicknames attribute does not work on our AADs because we don't sync from on-premise
#   # so we have to use user prinicpal names for lookups
#   user_principal_names = var.foundation_browser_members[*].upn
# }

# # todo: it would probably be a lot prettier to create an AAD group for the platform browsers and then assign those permissions
# # as long as this is all in terraform anyway it doesn't matter much though (terraform destroy is supported still)
# resource "azurerm_role_assignment" "foundation_browsers" {
#   for_each = toset(data.azuread_users.foundation_browser_members.object_ids)

#   principal_id       = each.key
#   role_definition_id = azurerm_role_definition.foundation_platform_browser.role_definition_resource_id
#   scope              = azurerm_management_group.platform.id
# }
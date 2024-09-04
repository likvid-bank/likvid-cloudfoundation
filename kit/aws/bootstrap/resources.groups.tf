resource "aws_identitystore_group" "platform_engineers" {
  display_name      = var.platform_engineers_group.name
  description       = "Privileged Cloud Foundation group. Members have full access to deploy cloud foundation infrastructure and landing zones."
  identity_store_id = local.identity_store_id
}

data "aws_identitystore_user" "platform_engineers" {
  for_each = var.platform_engineers_group.members

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_identitystore_group_membership" "members" {
  for_each = data.aws_identitystore_user.platform_engineers

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.platform_engineers.group_id
  member_id         = data.aws_identitystore_user.platform_engineers[each.key].user_id
}
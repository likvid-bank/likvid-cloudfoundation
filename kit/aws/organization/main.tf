data "aws_organizations_organization" "org" {
}

locals {
  org_root = data.aws_organizations_organization.org.roots[0].id
}


resource "aws_organizations_organizational_unit" "parent" {
  name      = var.parent_ou_name
  parent_id = local.org_root
}

# resource "aws_organizations_organizational_unit" "admin" {
#   name      = "admin"
#   parent_id = aws_organizations_organizational_unit.parent.id
# }
#
# # we have to configure these accounts here so that we can configure terraform
# # providers that authenticate into these accounts from for executing other kit modules
# resource "aws_organizations_account" "automation" {
#   name      = "automation"
#   email     = var.automation_account_email
#   parent_id = aws_organizations_organizational_unit.admin.id
#
#   // changing name forces replacement, so we ignore it to better support importing existing accounts
#   lifecycle {
#     ignore_changes = [tags, tags_all, name]
#   }
# }
#
# resource "aws_organizations_account" "network_management" {
#   name      = "network-management"
#   email     = var.network_management_account_email
#   parent_id = aws_organizations_organizational_unit.admin.id
#
#   lifecycle {
#     ignore_changes = [tags, tags_all, name]
#   }
# }
#
# resource "aws_organizations_account" "meshstack" {
#   name      = "meshcloud"
#   email     = var.meshstack_account_email
#   parent_id = aws_organizations_organizational_unit.admin.id
#
#   lifecycle {
#     ignore_changes = [tags, tags_all, name]
#   }
# }

resource "aws_organizations_organizational_unit" "landingzones" {
  name      = "${var.parent_ou_name}-landingzones"
  parent_id = aws_organizations_organizational_unit.parent.id
}

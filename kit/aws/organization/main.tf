data "aws_organizations_organization" "org" {
}

locals {
  org_root = data.aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "parent" {
  name      = var.parent_ou_name
  parent_id = local.org_root
}

resource "aws_organizations_organizational_unit" "landingzones" {
  name      = "${var.parent_ou_name}-landingzones"
  parent_id = aws_organizations_organizational_unit.parent.id
}

resource "aws_organizations_organizational_unit" "management" {
  name      = "${var.parent_ou_name}-management"
  parent_id = aws_organizations_organizational_unit.parent.id
}

resource "aws_organizations_account" "management_acc" {
  name      = "management_acc"
  email     = "aws+management-acc@meshcloud.io"
  parent_id = aws_organizations_organizational_unit.management.id
  #role_name = "OrganizationAccountAccessRole"
  lifecycle {
    ignore_changes = [tags, tags_all, name]
  }
}
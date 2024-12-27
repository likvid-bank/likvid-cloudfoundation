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

resource "aws_organizations_account" "management" {
  name      = "management_acc"
  email     = var.management_account_email
  parent_id = aws_organizations_organizational_unit.management.id

  // changing name forces replacement, so we ignore it to better support importing existing accounts
  lifecycle {
    ignore_changes = [tags, tags_all, name]
  }
}

resource "aws_organizations_account" "networking" {
  name      = "likvid-networking"
  email     = var.network_management_account_email
  parent_id = aws_organizations_organizational_unit.management.id

  // changing name forces replacement, so we ignore it to better support importing existing accounts
  lifecycle {
    ignore_changes = [tags, tags_all, name]
  }
}

resource "aws_organizations_account" "automation" {
  name      = "automation_acc"
  email     = var.automation_account_email
  parent_id = aws_organizations_organizational_unit.management.id

  // changing name forces replacement, so we ignore it to better support importing existing accounts
  lifecycle {
    ignore_changes = [tags, tags_all, name]
  }
}

resource "aws_organizations_account" "meshstack" {
  name      = "meshstack_acc"
  email     = var.meshstack_account_email
  parent_id = aws_organizations_organizational_unit.management.id

  // changing name forces replacement, so we ignore it to better support importing existing accounts
  lifecycle {
    ignore_changes = [tags, tags_all, name]
  }
}

# SSO access to management, networking, automation and meshstack accounts

data "aws_ssoadmin_instances" "sso" {}

locals {
  aws_sso_instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0] // note: we just assume ther's only one SSO instance in the account
}

data "aws_ssoadmin_permission_set" "admin" {
  instance_arn = local.aws_sso_instance_arn
  name         = "AWSAdministratorAccess"
}

data "aws_identitystore_user" "users" {
  for_each = toset(var.admin_users)

  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

locals {
  _user_ids = [for user in values(data.aws_identitystore_user.users) : user.id]
  _aws_accounts = [
    aws_organizations_account.management.id,
    aws_organizations_account.networking.id,
    aws_organizations_account.automation.id,
    aws_organizations_account.meshstack.id
  ]

  user_account_combinations = flatten([for s in setproduct(local._user_ids, local._aws_accounts) : "${s[0]}|${s[1]}"])
}

resource "aws_ssoadmin_account_assignment" "admin" {
  for_each = toset(local.user_account_combinations)

  instance_arn       = data.aws_ssoadmin_permission_set.admin.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.admin.arn

  principal_id   = split("|", each.key)[0]
  principal_type = "USER"

  target_id   = split("|", each.key)[1]
  target_type = "AWS_ACCOUNT"
}

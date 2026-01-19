data "oci_identity_users" "all_users" {
  compartment_id = var.tenancy_ocid
}

locals {
  compartment_name = "${var.foundation}-${var.workspace_id}-${var.project_id}"

  user_ocid_map = {
    for user in data.oci_identity_users.all_users.users :
    user.email => user.id
  }

  admin_users  = { for user in var.users : user.email => lookup(local.user_ocid_map, user.email, null) if contains(user.roles, "admin") && lookup(local.user_ocid_map, user.email, null) != null }
  user_users   = { for user in var.users : user.email => lookup(local.user_ocid_map, user.email, null) if contains(user.roles, "user") && !contains(user.roles, "admin") && lookup(local.user_ocid_map, user.email, null) != null }
  reader_users = { for user in var.users : user.email => lookup(local.user_ocid_map, user.email, null) if contains(user.roles, "reader") && !contains(user.roles, "admin") && !contains(user.roles, "user") && lookup(local.user_ocid_map, user.email, null) != null }
}

resource "oci_identity_compartment" "application" {
  compartment_id = var.parent_compartment_id
  name           = local.compartment_name
  description    = "Application compartment for ${var.workspace_id}/${var.project_id}"
}

resource "oci_identity_group" "readers" {
  compartment_id = var.tenancy_ocid
  name           = "${local.compartment_name}-readers"
  description    = "Read-only access to ${local.compartment_name}"
}

resource "oci_identity_group" "users" {
  compartment_id = var.tenancy_ocid
  name           = "${local.compartment_name}-users"
  description    = "User access to ${local.compartment_name}"
}

resource "oci_identity_group" "admins" {
  compartment_id = var.tenancy_ocid
  name           = "${local.compartment_name}-admins"
  description    = "Admin access to ${local.compartment_name}"
}

resource "oci_identity_user_group_membership" "readers" {
  for_each = local.reader_users

  group_id = oci_identity_group.readers.id
  user_id  = each.value
}

resource "oci_identity_user_group_membership" "users" {
  for_each = local.user_users

  group_id = oci_identity_group.users.id
  user_id  = each.value
}

resource "oci_identity_user_group_membership" "admins" {
  for_each = local.admin_users

  group_id = oci_identity_group.admins.id
  user_id  = each.value
}

resource "oci_identity_policy" "application" {
  compartment_id = oci_identity_compartment.application.id
  name           = "${local.compartment_name}-policy"
  description    = "Access policies for ${local.compartment_name}"

  statements = [
    "Allow group ${oci_identity_group.readers.name} to read all-resources in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to manage instance-family in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to manage virtual-network-family in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to manage volume-family in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to manage object-family in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to manage load-balancers in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.users.name} to read all-resources in compartment id ${oci_identity_compartment.application.id}",
    "Allow group ${oci_identity_group.admins.name} to manage all-resources in compartment id ${oci_identity_compartment.application.id}",
  ]
}

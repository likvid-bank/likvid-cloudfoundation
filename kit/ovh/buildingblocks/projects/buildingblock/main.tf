locals {
  processed_users = {
    for user in var.users : user.email => user
  }

  # For SAML federated users - correct URN format from logs
  admin_urns = [
    for email, user in local.processed_users :
    "urn:v1:eu:identity:user:${var.ovh_account_id}/provider/${user.email}"
    if contains(user.roles, "admin")
  ]

  user_urns = [
    for email, user in local.processed_users :
    "urn:v1:eu:identity:user:${var.ovh_account_id}/provider/${user.email}"
    if contains(user.roles, "user")
  ]

  reader_urns = [
    for email, user in local.processed_users :
    "urn:v1:eu:identity:user:${var.ovh_account_id}/provider/${user.email}"
    if contains(user.roles, "reader")
  ]
}

data "ovh_me" "myaccount" {}

data "ovh_order_cart" "mycart" {
  ovh_subsidiary = data.ovh_me.myaccount.ovh_subsidiary
}

data "ovh_order_cart_product_plan" "cloud" {
  cart_id        = data.ovh_order_cart.mycart.id
  price_capacity = "renew"
  product        = "cloud"
  plan_code      = "project.2018"
}

resource "ovh_cloud_project" "cloud_project" {
  ovh_subsidiary = data.ovh_order_cart.mycart.ovh_subsidiary
  description    = "${var.workspace_id}-${var.project_id}"
  plan {
    duration     = data.ovh_order_cart_product_plan.cloud.selected_price[0].duration
    pricing_mode = data.ovh_order_cart_product_plan.cloud.selected_price[0].pricing_mode
    plan_code    = data.ovh_order_cart_product_plan.cloud.plan_code
  }
}

# Admin: full access
resource "ovh_iam_policy" "admin" {
  for_each    = length(local.admin_urns) > 0 ? { "admin" = true } : {}
  name        = "${var.workspace_id}-${var.project_id}-admin"
  description = "Administrator full access policy for ${var.workspace_id}-${var.project_id}"
  identities  = local.admin_urns
  resources   = [ovh_cloud_project.cloud_project.urn]

  allow = [
    "publicCloudProject:apiovh:*"
  ]
}

resource "ovh_iam_policy" "user" {
  for_each    = length(local.user_urns) > 0 ? { "user" = true } : {}
  name        = "${var.workspace_id}-${var.project_id}-user"
  description = "User operate policy for ${var.workspace_id}-${var.project_id}"
  identities  = local.user_urns
  resources   = [ovh_cloud_project.cloud_project.urn]

  # broad allow for operations
  allow = [
    "publicCloudProject:apiovh:*"
  ]

  # lock down risky stuff
  except = [
    # general
    "publicCloudProject:apiovh:*/delete",
    "publicCloudProject:apiovh:*/edit",
    "publicCloudProject:apiovh:*iam/*",
    "publicCloudProject:apiovh:user/*",
    "publicCloudProject:apiovh:*role/*",
    "publicCloudProject:apiovh:*confirmTermination",
    "publicCloudProject:apiovh:*terminate",

    # object storage deletes (explicit)
    "publicCloudProject:apiovh:storage/delete",
    "publicCloudProject:apiovh:region/storage/delete",
    "publicCloudProject:apiovh:region/storage/object/delete",
    "publicCloudProject:apiovh:region/storage/object/version/delete",
    "publicCloudProject:apiovh:region/storage/bulkDeleteObjects",

    # block assuming OpenStack roles (objectstoreOperator etc.)
    "publicCloudProject:openstack:*"
  ]

  # belt & suspenders: hard deny
  deny = [
    "publicCloudProject:apiovh:*/delete",
    "publicCloudProject:openstack:*"
  ]
}

# Reader: read-only (GET)
resource "ovh_iam_policy" "reader" {
  for_each    = length(local.reader_urns) > 0 ? { "reader" = true } : {}
  name        = "${var.workspace_id}-${var.project_id}-reader"
  description = "Read-only access policy for ${var.workspace_id}-${var.project_id}"
  identities  = local.reader_urns
  resources   = [ovh_cloud_project.cloud_project.urn]

  allow = [
    "publicCloudProject:apiovh:get",
    "publicCloudProject:apiovh:*:get"
  ]
}

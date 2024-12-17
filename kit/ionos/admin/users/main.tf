resource "ionoscloud_user" "user" {
  for_each = {
    for index, user in var.users :
    user.email => user
  }

  email          = each.value.email
  first_name     = each.value.firstname
  last_name      = each.value.lastname
  password       = random_password.password[each.value.email].result
  active         = true
  administrator  = false
  force_sec_auth = false
}

resource "random_password" "password" {
  for_each = {
    for index, user in var.users :
    user.email => user
  }

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Ideally it would be a new kit "meshplatform" that only has the required access to:
# - create a VDC
# - assign users to that VDC
# But only "administrator = true" users can manage user access in IONOS, so there is no real benefit of adding another kit instead
resource "ionoscloud_user" "api_user" {
  for_each = {
    for index, user in var.api_users :
    user.email => user
  }

  email          = each.value.email
  first_name     = each.value.firstname
  last_name      = each.value.lastname
  password       = random_password.api_user_password[each.value.email].result
  active         = true
  administrator  = true
  force_sec_auth = false
}

resource "random_password" "api_user_password" {
  for_each = {
    for index, user in var.api_users :
    user.email => user
  }

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

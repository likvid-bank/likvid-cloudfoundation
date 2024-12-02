resource "ionoscloud_user" "api" {
  email          = var.email
  first_name     = var.firstname
  last_name      = var.lastname
  password       = random_password.api.result
  active         = true
  administrator  = true
  force_sec_auth = false
}

resource "random_password" "api" {
  length           = 16
  special          = true
  override_special = "_@+-!=*"
}

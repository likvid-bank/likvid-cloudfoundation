output "api_user" {
  sensitive = true
  value = {
    username = ionoscloud_user.api.email
    password = ionoscloud_user.api.password
  }
}

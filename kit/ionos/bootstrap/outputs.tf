output "user_passwords" {
  value = {
    for index, password in random_password.password :
    index => password.result
  }
  description = "User passwords"
  sensitive   = true
}

output "admin_passwords" {
  value = {
    for index, password in random_password.admin_password :
    index => password.result
  }
  description = "User passwords"
  sensitive   = true
}

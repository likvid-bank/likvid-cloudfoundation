output "user_passwords" {
  value = {
    for index, password in random_password.password :
    index => password.result
  }
  description = "User passwords"
  sensitive   = true
}

output "api_user_passwords" {
  value = {
    for index, password in random_password.api_user_password :
    index => password.result
  }
  description = "User passwords"
  sensitive   = true
}

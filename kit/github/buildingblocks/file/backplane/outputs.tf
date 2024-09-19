output "github_app_pem_file" {
  value     = data.bitwarden_attachment.github_app_pem_file.content
  sensitive = true
}

output "github_app_id_and_installation_id" {
  value     = data.bitwarden_item_login.github_app.notes
  sensitive = true
}

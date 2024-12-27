output "organization_id" {
  value = local.organization_id
}

output "root_folder_id" {
  value = data.google_folder.parent.name
}

output "admin_folder_id" {
  value = google_folder.admin.id
}

output "likvid_dev_folder_id" {
  value = google_folder.dev.id
}

output "likvid_prod_folder_id" {
  value = google_folder.prod.id
}

output "lookerstudio_report_url" {
  value = module.data_warehouse.lookerstudio_report_url
}

output "bigquery_editor_url" {
  value = module.data_warehouse.bigquery_editor_url
}

output "raw_bucket" {
  value = module.data_warehouse.raw_bucket
}

output "ds_friendly_name" {
  value = module.data_warehouse.ds_friendly_name
}

output "folder_id" {
  value = google_folder.data_lagoon.id
}

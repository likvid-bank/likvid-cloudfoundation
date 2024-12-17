output "parent_folder_id" {
  value = var.parent_folder_id
}

output "billing_account_id" {
  value = var.billing_account_id
}

output "github_actions_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "github_actions_validation_sa_email" {
  value = google_service_account.validation.email
}

output "platform_engineers_group_email" {
  value = data.google_cloud_identity_group_lookup.platform_engineers.group_key[0].id
}

output "platform_engineers_group_name" {
  value = var.platform_engineers_group.name
}

output "ci_service_account_email" {
  description = "Email of the CI service account used for GitHub Actions WIF authentication"
  value       = stackit_service_account.sa.email
}

output "ci_service_account_project_id" {
  description = "STACKIT project ID that owns the CI service account"
  value       = stackit_service_account.sa.project_id
}

output "backplane-service-account-credentials" {
  value     = google_service_account_key.backend.private_key
  sensitive = true
}

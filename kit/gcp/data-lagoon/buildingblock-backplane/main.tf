data "google_storage_bucket" "backend" {
  name = "likvid-data-lagoon-bb-tf-backend"
}

resource "google_service_account" "backend" {
  project      = "data-lagoon-prod-45o"
  account_id   = "data-lagoon-service-account"
  display_name = "Data Lagoon Building Block Backplane Service Account"
}

resource "google_service_account_key" "backend" {
  service_account_id = google_service_account.backend.name
}


# Access to backplane
resource "google_project_iam_binding" "backend" {
  project = "data-lagoon-prod-45o"
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.backend.email}",
  ]
}

# Access to target projects
resource "google_folder_iam_binding" "servicemanagement" {
  folder = var.folder_id
  role   = "roles/servicemanagement.admin"

  members = [
    "serviceAccount:${google_service_account.backend.email}",
  ]
}

resource "google_folder_iam_binding" "serviceusage" {
  folder = var.folder_id
  role   = "roles/serviceusage.serviceUsageAdmin"

  members = [
    "serviceAccount:${google_service_account.backend.email}",
  ]
}


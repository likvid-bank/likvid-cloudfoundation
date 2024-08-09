terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.40.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_project_service" "serviceusage" {
  project                    = var.project_id
  service                    = "serviceusage.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "bigquery" {
  project                    = var.project_id
  service                    = "bigquery.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true

  depends_on = [google_project_service.serviceusage]
}


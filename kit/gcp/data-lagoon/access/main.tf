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

resource "google_project_service" "project" {
  project            = var.project_id
  service            = "bigquery.googleapis.com"
  disable_on_destroy = true
}


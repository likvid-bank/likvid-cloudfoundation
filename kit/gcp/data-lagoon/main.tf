terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.40.0"
    }
  }
}

provider "google" {
  # Configuration options
}

# We use a quick-start template from Google for our Data Warehouse
module "data_warehouse" {
  source                     = "terraform-google-modules/bigquery/google//modules/data_warehouse"
  project_id                 = var.project_id
  region                     = "europe-west1"
  enable_apis                = true
  force_destroy              = false
  text_generation_model_name = "text_generate_model"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.19.0" # restricted by meshplatform module
    }
  }
}

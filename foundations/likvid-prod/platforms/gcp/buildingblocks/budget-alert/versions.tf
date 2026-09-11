terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.25.0 added the `meshstack_tenants` data source this unit resolves the smoke-test
      # tenant's uuid through.
      version = ">= 0.25.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.12"
    }
  }
}

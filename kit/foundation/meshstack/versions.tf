terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }

    meshstack = {
      source                = "meshcloud/meshstack"
      version               = "~> 0.8.0"
    }
  }
}

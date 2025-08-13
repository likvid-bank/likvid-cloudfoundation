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

    github = {
      source  = "integrations/github"
      version = "6.3.0"
    }
  }
}

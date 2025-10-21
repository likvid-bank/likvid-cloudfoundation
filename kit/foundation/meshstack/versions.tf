terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }

    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.12.0"
    }

    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

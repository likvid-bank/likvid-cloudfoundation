terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.9.0"
    }

    # 0.26.8 finds the meshStack CLI profile by its endpoint.
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.26.8"
    }

    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

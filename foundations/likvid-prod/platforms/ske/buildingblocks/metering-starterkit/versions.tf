terraform {
  required_version = ">= 1.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.27.2"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0, < 1.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }
}

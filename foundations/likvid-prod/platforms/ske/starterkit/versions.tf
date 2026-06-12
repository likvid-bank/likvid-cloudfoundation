terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.22.0"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
  }
}

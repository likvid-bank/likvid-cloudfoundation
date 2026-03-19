terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.20.0"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
  }
}

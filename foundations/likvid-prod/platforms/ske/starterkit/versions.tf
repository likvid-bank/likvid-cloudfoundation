terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.25.4"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
  }
}

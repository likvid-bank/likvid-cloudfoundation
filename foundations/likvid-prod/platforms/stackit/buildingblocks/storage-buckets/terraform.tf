terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0"
    }
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.26.8 finds the meshStack CLI profile by its endpoint.
      version = ">= 0.26.8"
    }
  }
}

terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.26.8 finds the meshStack CLI profile by its endpoint.
      version = ">= 0.26.8"
    }
  }
}

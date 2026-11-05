terraform {
  required_version = ">= 1.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.27.0 adds status.succeeded.
      version = ">= 0.27.0"
    }
  }
}

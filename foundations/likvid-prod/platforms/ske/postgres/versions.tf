terraform {
  required_version = ">= 1.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.28.1 is the first release with the input source LANDING_ZONE_IDENTIFIER.
      version = ">= 0.28.1"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0, < 1.0.0"
    }
  }
}

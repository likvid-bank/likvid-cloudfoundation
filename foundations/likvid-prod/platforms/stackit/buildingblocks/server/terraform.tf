terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0, < 1.0.0"
    }
    meshstack = {
      source = "meshcloud/meshstack"
      # The hub module's own floor.
      version = ">= 0.26.2"
    }
  }
}

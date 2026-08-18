terraform {
  required_version = ">= 1.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.24.0 for meshstack_workspace.spec.platform_builder_access_enabled and the computed `ref`.
      version = ">= 0.24.0"
    }
  }
}

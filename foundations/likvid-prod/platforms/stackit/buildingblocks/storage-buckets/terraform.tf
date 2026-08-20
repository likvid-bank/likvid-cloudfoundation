terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.98.0"
    }
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.24.3 added the `meshstack_platforms` data source this unit resolves `spec.platform_ref`
      # through; 0.24.0 through 0.24.2 do not have it.
      version = ">= 0.24.3"
    }
  }
}

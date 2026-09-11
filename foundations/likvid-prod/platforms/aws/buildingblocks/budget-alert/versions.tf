terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.25.0 added the `meshstack_tenants` data source this unit resolves the smoke-test
      # tenant's uuid through.
      version = ">= 0.25.0"
    }
    aws = {
      source = "hashicorp/aws"
      # The hub module is still capped below 6.0, which is also why the shared OIDC provider (on
      # aws 6.x) is a separate unit.
      version = "~> 5.97"
    }
  }
}

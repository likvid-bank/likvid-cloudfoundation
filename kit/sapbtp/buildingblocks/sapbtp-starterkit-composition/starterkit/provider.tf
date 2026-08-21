terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.24.4 is the floor: 0.24.3 added the `meshstack_platforms` data source this module resolves
      # `spec.platform_ref` through, and 0.24.4 added the computed `ref` outputs the building blocks below
      # use for `target_ref`.
      #
      # The upper bound protects the `moved` blocks in `main.tf`. This module has no lock file — meshStack
      # picks a provider at run time — so an open-ended constraint would let a run take 0.26.0, which drops
      # both deprecated building block types *and* their state movers. Remove the bound together with the
      # `moved` blocks, once every live building block has run at least once on this code.
      version = ">= 0.24.4, < 0.26.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}

provider "meshstack" {
  endpoint = "https://federation.demo.meshcloud.io"
  # apikey    = local.api_credentials.key
  # apisecret = local.api_credentials.secret
}

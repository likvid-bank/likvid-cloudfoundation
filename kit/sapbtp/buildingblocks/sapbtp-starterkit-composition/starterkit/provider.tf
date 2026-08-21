terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.24.4 is the floor: 0.24.3 added the `meshstack_platforms` data source this module resolves
      # `spec.platform_ref` through, and 0.24.4 added the computed `ref` outputs the building blocks below
      # use for `target_ref`.
      version = ">= 0.24.4"
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

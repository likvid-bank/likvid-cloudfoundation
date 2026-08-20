terraform {
  required_providers {
    meshstack = {
      source = "meshcloud/meshstack"
      # 0.24.3 added the `meshstack_platforms` data source this module resolves `spec.platform_ref`
      # through (0.24.0 through 0.24.2 do not have it), and 0.24.1 renamed the tenant's
      # `status.tenant_identifier` to `status.tenant_name`, which the building blocks below read.
      version = ">= 0.24.3"
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

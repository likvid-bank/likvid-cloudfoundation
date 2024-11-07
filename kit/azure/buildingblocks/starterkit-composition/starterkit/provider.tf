terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "0.5.3"
    }
  }
}


provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = local.api_credentials[var.workspace_identifier].key
  apisecret = local.api_credentials[var.workspace_identifier].secret
}

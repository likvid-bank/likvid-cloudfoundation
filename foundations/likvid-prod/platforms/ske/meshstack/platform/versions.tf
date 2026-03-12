terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.3"
    }
  }
}

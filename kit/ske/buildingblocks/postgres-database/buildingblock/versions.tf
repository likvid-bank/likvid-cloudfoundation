terraform {
  required_version = ">= 1.0"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.110.0, < 1.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0, < 3.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.12.0, < 6.0.0"
    }
  }
}

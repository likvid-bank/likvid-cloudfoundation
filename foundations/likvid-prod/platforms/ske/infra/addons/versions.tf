terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}

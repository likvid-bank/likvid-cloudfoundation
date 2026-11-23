terraform {
  required_version = ">= 1.0"

  required_providers {
    stackit = {
      source = "stackitcloud/stackit"
      # 0.113 is the first release with the ephemeral SKE kubeconfig.
      version = ">= 0.113.0, < 1.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0, < 3.0.0"
    }
  }
}

terraform {
  required_providers {
    meshstack  = { source = "meshcloud/meshstack", version = "~> 0.26.5" }
    github     = { source = "integrations/github" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.35.1, < 3.0.0" }
  }
}

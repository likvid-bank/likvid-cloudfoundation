terraform {
  required_providers {
    # 0.26.8 finds the meshStack CLI profile by its endpoint.
    meshstack  = { source = "meshcloud/meshstack", version = ">= 0.26.8" }
    github     = { source = "integrations/github" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.35.1, < 3.0.0" }
  }
}

terraform {
  required_providers {
    # 0.26.8 finds the meshStack CLI profile by its endpoint.
    meshstack = { source = "meshcloud/meshstack", version = ">= 0.26.8" }
    github    = { source = "integrations/github" }
  }
}

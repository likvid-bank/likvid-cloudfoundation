terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.88.0"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.20.0"
    }
  }
}

provider "meshstack" {
}

provider "stackit" {
  experiments = ["iam"]
}

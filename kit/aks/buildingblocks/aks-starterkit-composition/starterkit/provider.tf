terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.24.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}

provider "meshstack" {
}

terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.8.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "meshstack" {
}

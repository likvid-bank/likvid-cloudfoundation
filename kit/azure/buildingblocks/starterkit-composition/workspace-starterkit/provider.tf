terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.7.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
  }
}


provider "meshstack" {
}


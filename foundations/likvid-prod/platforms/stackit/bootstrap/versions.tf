terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">=0.98"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

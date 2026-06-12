terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">=0.98"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 3.0.0"
    }
  }
}

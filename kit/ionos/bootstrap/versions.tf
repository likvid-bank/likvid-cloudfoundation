terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "= 6.4.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

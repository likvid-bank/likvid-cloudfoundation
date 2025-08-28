terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "1.5.0"
    }
  }
}

provider "ovh" {
  endpoint = "ovh-eu"
}

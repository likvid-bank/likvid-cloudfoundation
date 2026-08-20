terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
  }
}


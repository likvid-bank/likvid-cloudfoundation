terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "core"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }

    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}


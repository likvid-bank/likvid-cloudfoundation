terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }

    azapi = {
      source  = "Azure/azapi"
      version = ">=1.13.1"
    }
  }
}

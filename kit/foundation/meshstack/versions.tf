terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }

    meshstack = {
      source                = "meshcloud/meshstack"
      version               = "~> 0.5.0"
      configuration_aliases = [meshstack.azure_marketdata_connector, meshstack.static_website_assets]
    }
  }
}

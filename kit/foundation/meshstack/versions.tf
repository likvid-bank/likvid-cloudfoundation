terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }

    meshstack = {
      source                = "meshcloud/meshstack"
      version               = "~> 0.6.0"
      configuration_aliases = [meshstack.azure_marketdata_connector, meshstack.static_website_assets, meshstack.likvid_gov_guard, meshstack.sap_core_platform]
    }
  }
}

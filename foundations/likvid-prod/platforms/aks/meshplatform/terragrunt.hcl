include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

locals {
  # Pin hub ref for both module source and BBD implementation ref_name
  hub_git_ref = "main"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "aks"
  host           = "https://dev-oug61sf3.hcp.germanywestcentral.azmk8s.io:443"
}

provider "azuread" {
  tenant_id = "${include.platform.locals.platform_azure.azure.aadTenantId}"
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  tenant_id       = "${include.platform.locals.platform_azure.azure.aadTenantId}"
  subscription_id = "${include.platform.locals.platform_azure.azure.subscriptionId}"
}

provider "meshstack" {
  endpoint  = "https://federation.demo.meshcloud.io"
  apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
  apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
}
EOF
}

terraform {
  source = "https://github.com/meshcloud/meshstack-hub.git//modules/aks?ref=${local.hub_git_ref}"
}

inputs = {
  aks = {
    base_url        = "https://dev-oug61sf3.hcp.germanywestcentral.azmk8s.io:443"
    subscription_id = include.platform.locals.platform_azure.azure.subscriptionId
    cluster_name    = "dev-oug61sf3"
    resource_group  = "aks-rg"

    service_principal_name = "aks_replicator.${include.platform.locals.cloudfoundation}.meshcloud.io"
    create_password        = false
    workload_identity_federation = {
      issuer         = "https://container.googleapis.com/v1/projects/meshcloud-meshcloud--bc0/locations/europe-west1/clusters/meshstacks-ha"
      access_subject = "system:serviceaccount:meshcloud-demo:replicator"
    }

    metering_enabled   = false
    replicator_enabled = false
  }

  meshstack_platform = {
    owning_workspace_identifier = "admin"
    platform_identifier         = "aks"
    location_identifier         = "meshcloud-azure-dev"
    display_name                = "AKS Namespace"
    description                 = "Azure Kubernetes Service (AKS). Create a k8s namespace in our AKS cluster."
  }
}

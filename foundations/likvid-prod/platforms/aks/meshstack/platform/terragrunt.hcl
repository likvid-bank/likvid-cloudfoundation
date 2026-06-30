include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "meshstack" {
  config_path = ".."
  mock_outputs = {
    owning_workspace_identifier = "owning-workspace"
    subscription_id             = "00000000-0000-0000-0000-000000000000"
  }
}

dependency "kubernetes" {
  config_path = "../../kubernetes"
  mock_outputs = {
    kube_host              = "https://mock-kube-host"
    cluster_ca_certificate = "bW9jaw=="
    client_certificate     = "bW9jaw=="
    client_key             = "bW9jaw=="
    aks_cluster_name       = "mock-cluster"
    aks_resource_group     = "mock-rg"
    oidc_issuer_url        = "https://mock.oidc.io"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "kubernetes" {
    host                   = "${dependency.kubernetes.outputs.kube_host}"
    cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_ca_certificate}")
    client_certificate     = base64decode("${dependency.kubernetes.outputs.client_certificate}")
    client_key             = base64decode("${dependency.kubernetes.outputs.client_key}")
  }

  provider "azurerm" {
    features {}
    subscription_id = "${dependency.meshstack.outputs.subscription_id}"
    tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
  }

  provider "azuread" {
    tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
  }

  provider "meshstack" {
    endpoint  = "https://federation.demo.meshcloud.io"
    apikey    = "6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
    apisecret = "${get_env("MESHSTACK_API_KEY_CLOUDFOUNDATION")}"
  }
  EOF
}

inputs = {
  meshstack          = dependency.meshstack.outputs
  kube_host          = dependency.kubernetes.outputs.kube_host
  aks_cluster_name   = dependency.kubernetes.outputs.aks_cluster_name
  aks_resource_group = dependency.kubernetes.outputs.aks_resource_group
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "meshstack" {
  config_path = "../../meshstack"
  mock_outputs = {
    subscription_id = "00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "apply"]
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
  }
  mock_outputs_allowed_terraform_commands = ["plan", "apply"]
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "azurerm" {
    features {}
    tenant_id       = "${include.platform.locals.platform.azure.aadTenantId}"
    subscription_id = "${dependency.meshstack.outputs.subscription_id}"
  }

  provider "azuread" {
    tenant_id = "${include.platform.locals.platform.azure.aadTenantId}"
  }

  provider "kubernetes" {
    host                   = "${dependency.kubernetes.outputs.kube_host}"
    cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_ca_certificate}")
    client_certificate     = base64decode("${dependency.kubernetes.outputs.client_certificate}")
    client_key             = base64decode("${dependency.kubernetes.outputs.client_key}")
  }
  EOF
}

terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/github-connector/backplane?ref=281007cc070cf6f088a325de30c34f3ec0e45b24"
}

inputs = {
  resource_prefix = "lcf-github-connector"

  aks = {
    cluster_name        = dependency.kubernetes.outputs.aks_cluster_name
    resource_group_name = dependency.kubernetes.outputs.aks_resource_group
  }

  acr = {
    location = "germanywestcentral"
  }
}

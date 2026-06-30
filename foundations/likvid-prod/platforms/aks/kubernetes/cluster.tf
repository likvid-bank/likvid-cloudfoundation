variable "subscription_id" {
  description = "Azure subscription ID provisioned by meshStack – used to scope the automation role assignment"
  type        = string
}

variable "platform_engineers_group" {
  description = "Display name of the Entra ID group that receives AKS cluster-admin access"
  type        = string
}

data "azuread_group" "platform_engineers" {
  display_name     = var.platform_engineers_group
  security_enabled = true
}

module "aks" {
  source = "github.com/meshcloud/meshstack-hub//modules/azure/aks/buildingblock?ref=281007cc070cf6f088a325de30c34f3ec0e45b24"

  resource_group_name = "aks-likvid"
  location            = "germanywestcentral"
  aks_cluster_name    = "aks-likvid"
  dns_prefix          = "likvid-aks"

  node_count          = 1
  enable_auto_scaling = true
  min_node_count      = 1
  max_node_count      = 3

  vm_size = "Standard_B2s_v2"

  aks_admin_group_object_id = data.azuread_group.platform_engineers.object_id

  tags = {
    Environment = "production"
    Platform    = "aks-namespace"
    ManagedBy   = "likvid-cloudfoundation"
  }

  providers = {
    azurerm.hub = azurerm.hub
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-likvid"
  resource_group_name = "aks-likvid"

  depends_on = [module.aks]
}

output "kube_host" {
  description = "Kubernetes API server URL"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Base64-encoded client certificate"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64-encoded client key"
  value       = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key
  sensitive   = true
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = data.azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  value       = data.azurerm_kubernetes_cluster.aks.resource_group_name
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = module.aks.oidc_issuer_url
}

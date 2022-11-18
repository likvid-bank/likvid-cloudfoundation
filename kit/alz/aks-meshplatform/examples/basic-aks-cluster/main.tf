provider "azurerm" {
  subscription_id = var.subscription_id
  alias           = "kubernetes-azurerm"
  features {
    resource_group {
    prevent_deletion_if_contains_resources = false
  }
}
}
resource "azurerm_resource_group" "aks-demo-cluster" {
  name     = "aks-demo-cluster"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks-demo-cluster" {
  name                = "aks-demo-cluster"
  location            = azurerm_resource_group.aks-demo-cluster.location
  resource_group_name = azurerm_resource_group.aks-demo-cluster.name
  dns_prefix          = "aks-demo-cluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = false
    admin_group_object_ids = ["${var.aad_group_id}"]
  }
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.15.0"
    }
  }
}

# Kubernetes Namespace
resource "kubernetes_namespace" "meshcloud" {
  metadata {
    name = "meshcloud"
  }
}

module "meshcloud-service-account-meshfed-metering" {
  count     = var.metering_enabled ? 1 : 0
  source    = "./modules/meshcloud-service-account-meshfed-metering"
  namespace = kubernetes_namespace.meshcloud.metadata.0.name
}

module "meshcloud-service-account-meshfed-replicator" {
  count     = var.replicator_enabled ? 1 : 0
  source    = "./modules/meshcloud-service-account-meshfed-replicator"
  namespace = kubernetes_namespace.meshcloud.metadata.0.name
}

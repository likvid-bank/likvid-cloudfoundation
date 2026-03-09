terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
  }
}

variable "stackit_project_id" {
  description = "STACKIT project UUID"
  type        = string
}

locals {
  cluster_name = "starterkit"
}

resource "stackit_ske_cluster" "starterkit" {
  project_id = var.stackit_project_id
  name       = local.cluster_name

  node_pools = [
    {
      name               = "pool-1"
      machine_type       = "g2i.2" # general instances
      minimum            = 1
      maximum            = 3
      availability_zones = ["eu01-1"]
      max_surge          = 1
    }
  ]

  maintenance = {
    enable_kubernetes_version_updates    = true
    enable_machine_image_version_updates = true
    start                                = "01:00:00Z"
    end                                  = "02:00:00Z"
  }
}

resource "stackit_ske_kubeconfig" "starterkit" {
  project_id   = var.stackit_project_id
  cluster_name = stackit_ske_cluster.starterkit.name
  expiration   = "15552000" # 180 days
  refresh      = true
}

output "kube_host" {
  description = "Kubernetes API server URL"
  value       = yamldecode(stackit_ske_kubeconfig.starterkit.kube_config)["clusters"][0]["cluster"]["server"]
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = yamldecode(stackit_ske_kubeconfig.starterkit.kube_config)["clusters"][0]["cluster"]["certificate-authority-data"]
  sensitive   = true
}

output "client_certificate" {
  description = "Base64-encoded client certificate"
  value       = yamldecode(stackit_ske_kubeconfig.starterkit.kube_config)["users"][0]["user"]["client-certificate-data"]
  sensitive   = true
}

output "client_key" {
  description = "Base64-encoded client key"
  value       = yamldecode(stackit_ske_kubeconfig.starterkit.kube_config)["users"][0]["user"]["client-key-data"]
  sensitive   = true
}

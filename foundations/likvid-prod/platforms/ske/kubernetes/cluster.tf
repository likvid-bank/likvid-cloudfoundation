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

variable "cluster_name" {
  type = string
}

resource "stackit_ske_cluster" "this" {
  project_id = var.stackit_project_id
  name       = var.cluster_name # TODO check if a random suffix would be a good idea here (if it's a global name shared across whole STACKIT)?

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

moved {
  from = stackit_ske_cluster.starterkit
  to   = stackit_ske_cluster.this
}

resource "stackit_ske_kubeconfig" "this" {
  project_id   = var.stackit_project_id
  cluster_name = stackit_ske_cluster.this.name
  expiration   = "15552000" # 180 days
  refresh      = true
}

moved {
  from = stackit_ske_kubeconfig.starterkit
  to   = stackit_ske_kubeconfig.this
}

output "kubeconfig" {
  description = "Raw kubeconfig content for starterkit access."
  value       = yamldecode(stackit_ske_kubeconfig.this.kube_config)
  sensitive   = true
}

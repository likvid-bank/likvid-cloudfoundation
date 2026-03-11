terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.3"
    }
  }
}

variable "kube_host" {
  description = "Kubernetes API server URL"
  type        = string
}

module "backplane" {
  source = "./backplane"
}

data "meshstack_workspace" "devops_platform" {
  metadata = {
    name = "devops-platform"
  }
}

resource "meshstack_platform" "ske" {
  metadata = {
    name               = "ske-namespace"
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
  }

  spec = {
    display_name      = "Kubernetes namespace on SKE"
    description       = "Provides a kubernetes namespace on STACKIT Kubernetes Engine (SKE)."
    endpoint          = var.kube_host
    documentation_url = ""
    support_url       = ""

    location_ref = {
      name = "sovereign"
    }

    availability = {
      publication_state        = "PUBLISHED"
      restriction              = "PUBLIC"
      restricted_to_workspaces = []
    }

    contributing_workspaces = []

    config = {
      kubernetes = {
        base_url               = var.kube_host
        disable_ssl_validation = true

        replication = {
          client_config = {
            access_token = {
              secret_value = module.backplane.replicator_token
            }
          }
          namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"
        }

        metering = {
          client_config = {
            access_token = {
              secret_value = module.backplane.metering_token
            }
          }
          processing = {
            compact_timelines_after_days = 30
            delete_raw_data_after_days   = 65
          }
        }
      }
    }

    # Cluster sizing: 2 vCPU + 8 Gi RAM per node, 1 node default / 3 node max.
    # Expected density: 20-30 illustration namespaces across the cluster.
    # CPU in millicores (m), memory in mebibytes (Mi) so values stay whole integers.
    quota_definitions = [
      {
        quota_key               = "limits.cpu"
        label                   = "CPU limit"
        description             = "The sum of CPU limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 1000 # 1 vCPU per namespace
        auto_approval_threshold = 1000
      },
      {
        quota_key               = "requests.cpu"
        label                   = "CPU requests"
        description             = "The sum of CPU requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 1000
        auto_approval_threshold = 500
      },
      {
        quota_key               = "limits.memory"
        label                   = "Memory limit"
        description             = "The sum of memory limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 1024 # 1 Gi per namespace
        auto_approval_threshold = 1024
      },
      {
        quota_key               = "requests.memory"
        label                   = "Memory requests"
        description             = "The sum of memory requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 1024
        auto_approval_threshold = 512
      },
      {
        quota_key               = "requests.storage"
        label                   = "Total Storage Requests"
        description             = "Across all persistent volume claims, the sum of storage requests cannot exceed this value."
        unit                    = "Gi"
        min_value               = 0
        max_value               = 5
        auto_approval_threshold = 2
      },
      {
        quota_key               = "persistentvolumeclaims"
        label                   = "Persistent Volume Claims"
        description             = "The total number of PersistentVolumeClaims that can exist in the namespace."
        unit                    = ""
        min_value               = 0
        max_value               = 4
        auto_approval_threshold = 2
      },
    ]
  }
}

resource "meshstack_landingzone" "dev" {
  metadata = {
    name               = "ske-namespace-dev"
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
    tags = {
      "LandingZoneFamily" = ["cloud-native"]
      "environment"       = ["dev"]
      "confidentiality"   = ["internal", "public"]
    }
  }

  spec = {
    display_name                  = "SKE Kubernetes Namespace – Development"
    description                   = "Landing zone for development."
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/landingzones/dev.html"

    platform_ref = {
      uuid = meshstack_platform.ske.metadata.uuid
    }

    platform_properties = {
      kubernetes = {
        kubernetes_role_mappings = [
          {
            project_role_ref = { name = "admin" }
            platform_roles   = ["admin"]
          },
          {
            project_role_ref = { name = "user" }
            platform_roles   = ["edit"]
          },
          {
            project_role_ref = { name = "reader" }
            platform_roles   = ["view"]
          },
        ]
      }
    }

    quotas = [
      { key = "limits.cpu", value = 500 },
      { key = "requests.cpu", value = 250 },
      { key = "limits.memory", value = 512 },
      { key = "requests.memory", value = 256 },
      { key = "requests.storage", value = 1 },
      { key = "persistentvolumeclaims", value = 2 },
    ]
  }
}

resource "meshstack_landingzone" "prod" {
  metadata = {
    name               = "ske-namespace-prod"
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
    tags = {
      "LandingZoneFamily" = ["cloud-native"]
      "environment"       = ["prod"]
      "confidentiality"   = ["internal", "public"]
    }
  }

  spec = {
    display_name                  = "SKE Kubernetes Namespace – Production"
    description                   = "Landing zone for production workloads."
    automate_deletion_approval    = true
    automate_deletion_replication = true
    info_link                     = "https://likvid-bank.github.io/likvid-cloudfoundation/platforms/stackit/landingzones/prod.html"

    platform_ref = {
      uuid = meshstack_platform.ske.metadata.uuid
    }

    platform_properties = {
      kubernetes = {
        kubernetes_role_mappings = [
          {
            project_role_ref = { name = "admin" }
            platform_roles   = ["admin"]
          },
          {
            project_role_ref = { name = "user" }
            platform_roles   = ["edit"]
          },
          {
            project_role_ref = { name = "reader" }
            platform_roles   = ["view"]
          },
        ]
      }
    }

    quotas = [
      { key = "limits.cpu", value = 1000 },
      { key = "requests.cpu", value = 500 },
      { key = "limits.memory", value = 1024 },
      { key = "requests.memory", value = 512 },
      { key = "requests.storage", value = 2 },
      { key = "persistentvolumeclaims", value = 4 },
    ]
  }
}

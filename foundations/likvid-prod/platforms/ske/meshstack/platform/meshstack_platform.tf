output "full_platform_identifier" {
  description = "The meshstack platform identifier for SKE namespaces"
  # Sad that this it not a an output of the meshstack_platform resource
  value = "${meshstack_platform.this.metadata.name}.${meshstack_platform.this.spec.location_ref.name}"
}

module "meshplatform" {
  source = "git::https://github.com/meshcloud/terraform-kubernetes-meshplatform.git?ref=v0.2.0"

  replicator_enabled = true
  metering_enabled   = true
}

moved {
  from = meshstack_platform.ske
  to   = meshstack_platform.this
}

resource "meshstack_platform" "this" {
  metadata = {
    name               = "ske-namespace"
    owned_by_workspace = var.meshstack.owning_workspace_identifier
  }

  spec = {
    display_name      = "Kubernetes namespace on SKE"
    description       = "Provides a kubernetes namespace on STACKIT Kubernetes Engine (SKE)."
    endpoint          = var.kube_host
    documentation_url = ""
    support_url       = ""

    location_ref = {
      name = var.meshstack.location_identifier
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
              secret_value = module.meshplatform.replicator_token
            }
          }
          namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"
        }

        metering = {
          client_config = {
            access_token = {
              secret_value = module.meshplatform.metering_token
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

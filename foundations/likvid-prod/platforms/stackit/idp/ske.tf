# The deployment of the platform backplane lives at 
# https://github.com/meshcloud/stackit-idp-demo/tree/main/platform/01-ske/module
# and https://github.com/meshcloud/stackit-idp-demo/blob/main/platform/02-meshstack/module/main.tf
# and needs to be incorporated here in the future
resource "meshstack_platform" "ske" {
  metadata = {
    name               = "ske1"
    owned_by_workspace = "likvid-cloud"
  }
  spec = {
    availability = {
      publication_state        = "PUBLISHED"
      restricted_to_workspaces = []
      restriction              = "PUBLIC"
    }
    config = {
      aks     = null
      aws     = null
      azure   = null
      azurerg = null
      custom  = null
      gcp     = null
      kubernetes = {
        base_url               = "https://api.ske-demo.d2695c1f95.s.ske.eu01.onstackit.cloud"
        disable_ssl_validation = true
        metering = {
          client_config = {
            access_token = {
              secret_value   = "dummy" # sensitive write-only
              secret_version = "sha256:b065713e1396a66a3f411804a3a7db7fc89dc3d2ab7ece542e6f95e2c5bd7ca0"
            }
          }
          processing = {
            compact_timelines_after_days = 30
            delete_raw_data_after_days   = 65
          }
        }
        replication = {
          client_config = {
            access_token = {
              secret_value   = "dummy" # sensitive write-only
              secret_version = "sha256:870970a03a5d9beb3bf638acd329b64b7394b4b236a00c759aef94e76cbd9a1f"
            }
          }
          namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"
        }
      }
      openshift = null
    }
    contributing_workspaces = []
    description             = "STACKIT Kubernetes Engine (SKE) offers the quickest way to start developing and deploying cloud-native apps in Europe with data sovereignty, featuring fully managed Kubernetes clusters, automatic updates and repairs, flexible autoscaling, and seamless integration with STACKIT's secure cloud ecosystem."
    display_name            = "Web-App Env Python Backend on SKE"
    documentation_url       = ""
    endpoint                = "https://api.ske-demo.d2695c1f95.s.ske.eu01.onstackit.cloud"
    location_ref = {
      kind = "meshLocation"
      name = "sovereign"
    }
    quota_definitions = [{
      auto_approval_threshold = 1000
      description             = "The sum of memory limits across all pods in a non-terminal state cannot exceed this value."
      label                   = "Memory limit"
      max_value               = 2048
      min_value               = 0
      quota_key               = "limits.memory"
      unit                    = "Gi"
      }, {
      auto_approval_threshold = 1000
      description             = "The sum of memory requests across all pods in a non-terminal state cannot exceed this value"
      label                   = "Memory requests"
      max_value               = 2048
      min_value               = 0
      quota_key               = "requests.memory"
      unit                    = "Gi"
      }, {
      auto_approval_threshold = 2000
      description             = "Across all persistent volume claims, the sum of storage requests cannot exceed this value."
      label                   = "Total Storage Requests"
      max_value               = 100000
      min_value               = 0
      quota_key               = "requests.storage"
      unit                    = "Gi"
      }, {
      auto_approval_threshold = 32
      description             = "The total number of PersistentVolumeClaims that can exist in the namespace."
      label                   = "Persistent Volume Claims"
      max_value               = 1024
      min_value               = 0
      quota_key               = "persistentvolumeclaims"
      unit                    = ""
      }, {
      auto_approval_threshold = 500
      description             = "The sum of CPU limits across all pods in a non-terminal state cannot exceed this value."
      label                   = "CPU limit"
      max_value               = 10000
      min_value               = 0
      quota_key               = "limits.cpu"
      unit                    = ""
      }, {
      auto_approval_threshold = 500
      description             = "The sum of CPU requests across all pods in a non-terminal state cannot exceed this value."
      label                   = "CPU requests"
      max_value               = 10000
      min_value               = 0
      quota_key               = "requests.cpu"
      unit                    = ""
    }]
    support_url = ""
  }
}

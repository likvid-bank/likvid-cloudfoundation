variable "meshstack" {
  description = "Outputs from the parent meshstack unit (workspace, subscription_id)"
  type = object({
    owning_workspace_identifier = string
    subscription_id             = string
  })
}

variable "kube_host" {
  description = "Kubernetes API server URL"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  type        = string
}

data "meshstack_integrations" "integrations" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

module "meshplatform" {
  source  = "meshcloud/meshplatform/aks"
  version = "~> 0.2.0"

  namespace = "meshcloud"
  scope     = var.meshstack.subscription_id

  replicator_enabled     = true
  service_principal_name = "replicator.aks-namespace.likvid-prod.meshcloud.io"

  metering_enabled = true

  create_password = false
  workload_identity_federation = {
    issuer         = data.meshstack_integrations.integrations.workload_identity_federation.replicator.issuer
    access_subject = data.meshstack_integrations.integrations.workload_identity_federation.replicator.subject
  }
}

resource "meshstack_platform" "aks" {
  metadata = {
    name               = "aks-namespace"
    owned_by_workspace = var.meshstack.owning_workspace_identifier
  }

  spec = {
    display_name      = "AKS Namespace"
    description       = "Azure Kubernetes Service (AKS). Create a k8s namespace in our AKS cluster."
    endpoint          = var.kube_host
    documentation_url = ""
    support_url       = ""

    location_ref = {
      name = "global"
    }

    availability = {
      publication_state        = "PUBLISHED"
      restriction              = "PUBLIC"
      restricted_to_workspaces = []
    }

    contributing_workspaces = []

    config = {
      aks = {
        base_url               = var.kube_host
        disable_ssl_validation = true

        replication = {
          service_principal = {
            entra_tenant = data.azuread_domains.aad_domains.domains[0].domain_name
            client_id    = module.meshplatform.replicator_service_principal.Application_Client_ID
            object_id    = module.meshplatform.replicator_service_principal.Enterprise_Application_Object_ID

            auth = {
              credential = null
            }
          }

          access_token = {
            secret_value = module.meshplatform.replicator_token
          }

          group_name_pattern     = "aks-#{workspaceIdentifier}.#{projectIdentifier}-#{platformGroupAlias}"
          namespace_name_pattern = "#{workspaceIdentifier}-#{projectIdentifier}"

          user_lookup_strategy       = "UserByMailLookupStrategy"
          send_azure_invitation_mail = false
          redirect_url               = "https://portal.azure.com/#home"

          aks_subscription_id = var.meshstack.subscription_id
          aks_cluster_name    = var.aks_cluster_name
          aks_resource_group  = var.aks_resource_group
        }

        metering = {
          client_config = {
            access_token = {
              secret_value = module.meshplatform.metering_token
            }
          }
          processing = {}
        }
      }
    }

    quota_definitions = [
      {
        quota_key               = "limits.cpu"
        label                   = "CPU limit"
        description             = "The sum of CPU limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 2000
        auto_approval_threshold = 2000
      },
      {
        quota_key               = "requests.cpu"
        label                   = "CPU requests"
        description             = "The sum of CPU requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "m"
        min_value               = 0
        max_value               = 2000
        auto_approval_threshold = 1000
      },
      {
        quota_key               = "limits.memory"
        label                   = "Memory limit"
        description             = "The sum of memory limits across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 2048
        auto_approval_threshold = 2048
      },
      {
        quota_key               = "requests.memory"
        label                   = "Memory requests"
        description             = "The sum of memory requests across all pods in a non-terminal state cannot exceed this value."
        unit                    = "Mi"
        min_value               = 0
        max_value               = 2048
        auto_approval_threshold = 1024
      },
      {
        quota_key               = "requests.storage"
        label                   = "Total Storage Requests"
        description             = "Across all persistent volume claims, the sum of storage requests cannot exceed this value."
        unit                    = "Gi"
        min_value               = 0
        max_value               = 10
        auto_approval_threshold = 5
      },
      {
        quota_key               = "persistentvolumeclaims"
        label                   = "Persistent Volume Claims"
        description             = "The total number of PersistentVolumeClaims that can exist in the namespace."
        unit                    = ""
        min_value               = 0
        max_value               = 8
        auto_approval_threshold = 4
      },
    ]
  }
}

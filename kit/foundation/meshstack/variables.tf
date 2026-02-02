variable "meshstack_api" {
  description = "API user with access to meshStack"
  nullable    = false
  type = object({
    endpoint = string,
    username = string,
    password = string
  })
}

variable "meshpanel_base_url" {
  description = "Base URL of the meshPanel"
  nullable    = false
  type        = string
}


variable "demo_gitops" {
  description = "Configuration for the static website assets demos"
  nullable    = false
  sensitive   = true
  type = object({
    repository               = string,
    meshstack_api_key_id     = string,
    meshstack_api_key_secret = string
    aws_sso_instance_arn     = string,
    aws_identity_store_id    = string,
    gha_aws_role_to_assume   = string
  })
}

variable "azure_m25_platform" {
  description = "Configuration for Azure M25 platform and landing zones"
  nullable    = true
  default     = null
  sensitive   = true
  type = object({
    platform_identifier           = string
    display_name                  = string
    description                   = string
    documentation_url             = string
    location_ref_name             = string
    tenant_id                     = string
    replicator_auth_type          = string # Either "CREDENTIALS" or "WORKLOAD_IDENTITY"
    replicator_client_id          = string
    replicator_client_secret      = optional(string) # Only required if auth_type is "CREDENTIALS"
    replicator_object_id          = string
    subscription_owner_object_ids = list(string)
    subscription_name_pattern     = string
    group_name_pattern            = string
    azure_role_mappings = list(object({
      project_role_ref = object({
        name = string
      })
      azure_role = object({
        alias = string
        id    = string
      })
    }))
    sandbox_landing_zone = object({
      identifier                    = string
      display_name                  = string
      description                   = optional(string, "Sandbox environment for M25 developers")
      parent_management_group_id    = string
      automate_deletion_approval    = optional(bool, false)
      automate_deletion_replication = optional(bool, false)
      # Reuse the platform's role mappings for the landing zone
    })
  })

  validation {
    condition     = var.azure_m25_platform == null || contains(["CREDENTIALS", "WORKLOAD_IDENTITY"], var.azure_m25_platform.replicator_auth_type)
    error_message = "replicator_auth_type must be either 'CREDENTIALS' or 'WORKLOAD_IDENTITY'"
  }

  validation {
    condition     = var.azure_m25_platform == null || (var.azure_m25_platform.replicator_auth_type != "CREDENTIALS" || var.azure_m25_platform.replicator_client_secret != null)
    error_message = "replicator_client_secret is required when replicator_auth_type is 'CREDENTIALS'"
  }
}
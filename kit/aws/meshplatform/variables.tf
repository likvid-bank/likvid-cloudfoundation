variable "aws_sso_instance_arn" {
  type        = string
  description = "AWS SSO Instance ARN. Needs to be of the form arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxx. Setup instructions https://docs.meshcloud.io/docs/meshstack.aws.sso-setup.html."
}

variable "control_tower_enrollment_enabled" {
  type        = bool
  default     = false
  description = "Set to true, to allow meshStack to enroll Accounts via AWS Control Tower for the meshPlatform."
}

variable "control_tower_portfolio_id" {
  type        = string
  default     = ""
  description = "Must be set for AWS Control Tower"
}

variable "replicator_privileged_external_id" {
  type        = string
  description = "Set this variable to a random UUID version 4. The external id is a secondary key to make an AssumeRole API call."
  # validation {
  #   condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$", var.replicator_privileged_external_id))
  #   error_message = "Must be a valid UUID version 4."
  # }
}

variable "cost_explorer_privileged_external_id" {
  type        = string
  description = "Set this variable to a random UUID version 4. The external id is a secondary key to make an AssumeRole API call."
  # validation {
  #   condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$", var.cost_explorer_privileged_external_id))
  #   error_message = "Must be a valid UUID version 4."
  # }
}

variable "landing_zone_ou_arns" {
  type        = list(string)
  description = "Organizational Unit ARNs that are used in Landing Zones. We recommend to explicitly list the OU ARNs that meshStack should manage."
  default     = []
}

variable "can_close_accounts_in_resource_org_paths" {
  type = list(string)
  // see https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html#condition-keys-resourceorgpaths
  description = "AWS ResourceOrgPaths that are used in Landing Zones and where meshStack is allowed to close accounts."
  default     = [] // example: o-a1b2c3d4e5/r-f6g7h8i9j0example/ou-ghi0-awsccccc/ou-jkl0-awsddddd/
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "meshcloud_account_service_user_name" {
  type        = string
  default     = "meshfed-service-user"
  description = "Name of the meshfed-service user. This user is responsible for replication."
}

variable "management_account_service_role_name" {
  type        = string
  default     = "MeshfedServiceRole"
  description = "Name of the custom role in the management account. See https://docs.meshcloud.io/docs/meshstack.how-to.integrate-meshplatform-aws-manually.html#set-up-aws-account-2-management"
}

variable "automation_account_service_role_name" {
  type        = string
  default     = "MeshfedAutomationRole"
  description = "Name of the custom role in the automation account. See https://docs.meshcloud.io/docs/meshstack.how-to.integrate-meshplatform-aws-manually.html#set-up-aws-account-3-automation"
}

variable "cost_explorer_management_account_service_role_name" {
  type        = string
  default     = "MeshCostExplorerServiceRole"
  description = "Name of the custom role in the management account used by the cost explorer user."
}

variable "cost_explorer_meshcloud_account_service_user_name" {
  type        = string
  default     = "meshcloud-cost-explorer-user"
  description = "Name of the user using cost explorer service to collect metering data."
}

variable "support_root_account_via_aws_sso" {
  type        = bool
  default     = false
  description = "Set to true to allow meshStack to manage the Organization's AWS Root account's access via AWS SSO."
}

variable "create_access_keys" {
  type        = bool
  default     = true
  description = "Set to false to disable creation of any service account access keys."
}

variable "workload_identity_federation" {
  type = object({
    issuer             = string,
    audience           = string,
    thumbprint         = string,
    replicator_subject = string,
    kraken_subject     = string
  })
  default = null
}

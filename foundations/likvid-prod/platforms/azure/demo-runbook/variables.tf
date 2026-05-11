variable "output_dir" {
  type        = string
  description = "Absolute path to the demo-runbook source directory (set by Terragrunt via get_terragrunt_dir)"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD / Entra tenant ID"
}

# --- organization-hierarchy ---

variable "parent_mg_id" {
  type        = string
  description = "Resource ID of the parent (likvid-foundation) management group"
}

variable "landingzones_mg_id" {
  type        = string
  description = "Resource ID of the likvid-landingzones management group"
}

variable "platform_mg_id" {
  type        = string
  description = "Resource ID of the likvid-platform management group"
}

variable "connectivity_mg_id" {
  type        = string
  description = "Resource ID of the likvid-connectivity management group"
}

variable "identity_mg_id" {
  type        = string
  description = "Resource ID of the likvid-identity management group"
}

variable "management_mg_id" {
  type        = string
  description = "Resource ID of the likvid-management management group"
}

# --- logging ---

variable "law_workspace_id" {
  type        = string
  description = "Resource ID of the central Log Analytics Workspace"
}

variable "logging_subscription_id" {
  type        = string
  description = "Subscription ID hosting the Log Analytics Workspace"
}

variable "log_retention_days" {
  type        = number
  description = "Log retention period in days configured on the LAW"
}

# --- sandbox landing zone ---

variable "sandbox_mg_id" {
  type        = string
  description = "Resource ID of the sandbox management group"
}

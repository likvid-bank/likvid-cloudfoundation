variable "name" {
  type        = string
  nullable    = false
  default     = "budget-alert"
  description = "name of the building block, used for naming resources"
  validation {
    condition     = can(regex("^[-a-z0-9]+$", var.name))
    error_message = "Only alphanumeric lowercase characters and dashes are allowed"
  }
}

variable "service_principal_name" {
  type        = string
  nullable    = false
  description = "name of the Service Principal used to perform all deployments of this building block"
}

variable "location" {
  type        = string
  nullable    = false
  description = "Azure location for deploying the building block terraform state storage account"
}

variable "scope" {
  type        = string
  nullable    = false
  description = "Scope where the building block should be deployable, typically the parent of all Landing Zones."
}

variable "bb_admins_group_id" {
  type        = string
  nullable    = false
  description = "Id of an AAD group for platform engineers working with the buidling block"
}
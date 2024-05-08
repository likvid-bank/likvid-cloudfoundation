variable "parent_management_group_id" {
  description = "The tenant management group of your cloud foundation"
  default     = "foundation"
}

variable "landingzones" {
  description = "The parent_management_group where your landingzones are"
  default     = "landingzones"
}

variable "lz-container-platform" {
  default = "container-platform"
}

variable "location" {
  type        = string
  description = "The Azure location where this policy assignment should exist, required when an Identity is assigned."
  default     = "germanywestcentral"
}

variable "email_receiver" {
  type        = string
  description = "The email address of the receiver"
  default     = "meshi@meshithesheep.io"
}

variable "k8s_monitoring_rg_name" {
  type        = string
  description = "The name of the resource group for the monitoring"
  default     = "k8s-monitoring-rg"
}

variable "law_workspace_id" {
  type        = string
  description = "The id of the log analytics workspace"
}

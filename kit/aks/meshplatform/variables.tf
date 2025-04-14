variable "metering_enabled" {
  type    = bool
  default = true
}

variable "metering_additional_rules" {
  type = list(object({
    api_groups        = list(string)
    resources         = list(string)
    verbs             = list(string)
    resource_names    = optional(list(string))
    non_resource_urls = optional(list(string))
  }))
  default = []
}

variable "replicator_enabled" {
  type    = bool
  default = true
}

variable "replicator_additional_rules" {
  type = list(object({
    api_groups        = list(string)
    resources         = list(string)
    verbs             = list(string)
    resource_names    = optional(list(string))
    non_resource_urls = optional(list(string))
  }))
  default = []
}

variable "create_password" {
  type    = bool
  default = true
}

variable "service_principal_name" {
  type = string
}

variable "scope" {
  type = string
}

variable "workload_identity_federation" {
  default     = null
  description = "Enable workload identity federation instead of using a password by providing these additional settings. Usually you should receive the required settings when attempting to configure a platform with workload identity federation in meshStack."
  type        = object({ issuer = string, replicator_subject = string })
}

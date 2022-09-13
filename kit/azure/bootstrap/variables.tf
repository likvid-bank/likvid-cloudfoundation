
variable "terraform_state_storage" {
  type = object({
    location = string
  })
  nullable    = true
  default     = null
  description = "Configure this object to enable setting up a terraform state store in Azure Storage."
}

variable "platform_engineers_members" {
  description = "Platform engineers with access to this platform's terraform state"
  type = list(object({
    email = string,
    upn   = string,
  }))
}

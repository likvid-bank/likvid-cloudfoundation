variable "location" {
    description = "Azure location for deploying resources"
    type = string
    nullable = false
}

variable "platform_engineers_members" {
  description = "Platform engineers with access to this platform's terraform state"
  type = list(object({
    email = string,
    upn   = string,
  }))
}

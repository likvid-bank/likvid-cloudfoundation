variable "workspace_identifier" {
  type = string
}

variable "name" {
  type        = string
  description = "This name will be used for the projects, AKS namespaces & GitHub repository"
}

variable "creator" {
  type = object({
    type        = string
    identifier  = string
    displayName = string
    username    = optional(string)
    email       = optional(string)
    euid        = optional(string)
  })
  description = "Information about the creator of the resources who will be assigned Project Admin role"
}


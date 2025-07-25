variable "workspace_identifier" {
  type = string
}

variable "name" {
  type        = string
  description = "Display Name of of the projects and resources created."
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

variable "github_username" {
  type        = string
  default     = null
  description = "GitHub username that shall be granted admin rights on the created repository"
}


variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "stackit_access_token" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "Access token of a STACKIT login that may grant roles on the shared instances' project."
}

variable "order_instances" {
  type        = bool
  default     = true
  description = "False registers the definitions without ordering the instances, so the platform can federate the definitions before their first run."
}

variable "parent_compartment_id" {
  type        = string
  description = "OCID of the parent compartment (typically the tenancy root compartment)"
}

variable "sandbox_users_group" {
  type        = string
  description = "Name of the IAM group for sandbox users"
  default     = "sandbox-users"
}

variable "foundation" {
  type        = string
  description = "Name of the foundation"
}

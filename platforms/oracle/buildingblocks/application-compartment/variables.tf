variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
}

variable "parent_compartment_id" {
  type        = string
  description = "OCID of the parent compartment where the application compartment will be created"
}

variable "foundation" {
  type        = string
  description = "Foundation name prefix"
}

variable "workspace_id" {
  type        = string
  description = "Workspace identifier (e.g., team name or business unit)"
}

variable "project_id" {
  type        = string
  description = "Project identifier (e.g., application name)"
}

variable "users" {
  description = "List of users from authoritative system"
  type = list(object({
    meshIdentifier = string
    username       = string
    firstName      = string
    lastName       = string
    email          = string
    euid           = string
    roles          = list(string)
  }))
  default = []
}

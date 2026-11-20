variable "workspace_identifier" {
  type        = string
  nullable    = false
  description = "meshStack workspace of the building block. Database and user are named `<workspace>_<project>`."
}

variable "project_identifier" {
  type        = string
  nullable    = false
  description = "meshStack project of the building block. Database and user are named `<workspace>_<project>`."
}

variable "namespace" {
  type        = string
  nullable    = false
  description = "Kubernetes namespace of the tenant, which receives the Secret."
}

variable "landing_zone_identifier" {
  type        = string
  nullable    = false
  description = "Landing zone of the tenant. It selects the shared instance."
}

variable "instance_ids" {
  type        = map(string)
  nullable    = false
  description = "ID of the shared PostgreSQL Flex instance per landing zone identifier."
}

variable "stackit_project_id" {
  type        = string
  nullable    = false
  description = "STACKIT project of the shared instances."
}

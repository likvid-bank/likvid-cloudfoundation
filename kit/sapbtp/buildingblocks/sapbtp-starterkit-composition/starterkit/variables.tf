variable "workspace_identifier" {
  default = "sap-core-platform"
  type    = string
}

variable "name" {
  type        = string
  default     = "testsap"
  description = "Name of of the resources and the repository to connect."
}

variable "subfolder" {
  type        = string
  default     = "likvid-a-001"
  description = "The subfolder to use for the SAP BTP resources. This is used to create a folder structure in the SAP BTP cockpit."
}

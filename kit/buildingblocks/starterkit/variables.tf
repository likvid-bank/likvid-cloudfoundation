variable "service_principal_name" {
  type        = string
  description = "name of the Service Principal used to perform all deployments of this building block"
}

variable "location" {
  type        = string
  nullable    = false
  description = "Azure location for deploying the building block terraform state storage account"
}

variable "scope" {
  type        = string
  nullable    = false
  description = "Scope where the building block should be deployable, typically a Sandbox Landing Zone Management Group"
}
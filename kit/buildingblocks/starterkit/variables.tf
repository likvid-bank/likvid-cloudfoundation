variable "service_principal_name" {
  type        = string
  description = "name of the Service Principal used to perform all deployments of this building block"
}

variable "location" {
  type        = string
  nullable    = false
  description = "Azure location for deploying the building block terraform state storage account"
}
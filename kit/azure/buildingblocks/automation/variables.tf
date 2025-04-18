variable "location" {
  type        = string
  nullable    = false
  description = "Azure location for deploying the storage account"
}

variable "service_principal_name" {
  type     = string
  nullable = false
}

variable "scope" {
  type     = string
  nullable = false
}

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the OCI tenancy"
}

variable "foundation_compartment_ocid" {
  type        = string
  description = "The OCID of the foundation compartment where resources will be created"
}

variable "foundation_name" {
  type        = string
  description = "Name of the foundation (used for naming resources)"
}

variable "home_region" {
  type        = string
  description = "The home region of the OCI tenancy"
}

variable "platform_engineers_group" {
  type = object({
    name    = string
    members = set(string)
  })
  description = "Platform engineers group configuration with name and member user OCIDs"
}

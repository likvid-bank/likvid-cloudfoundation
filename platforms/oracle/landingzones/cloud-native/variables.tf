variable "parent_compartment_id" {
  type        = string
  description = "OCID of the parent compartment (typically the tenancy root compartment)"
}

variable "cloud_native_users_group" {
  type        = string
  description = "Name of the IAM group for cloud-native users with dev access"
  default     = "cloud-native-users"
}

variable "cloud_native_admins_group" {
  type        = string
  description = "Name of the IAM group for cloud-native administrators"
  default     = "cloud-native-admins"
}

variable "foundation" {
  type        = string
  description = "Name of the foundation"
}

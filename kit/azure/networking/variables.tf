variable "scope" {
  description = "id of the management group that you want to manage spokes in"
}

variable "cloudfoundation_deploy_principal_id" {
}

variable "parent_management_group_id" {
}

variable "location" {
}

variable "address_space" {
  type = list(string)
}


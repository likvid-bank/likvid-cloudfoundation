variable "hub_rg" {
}

variable "hub_vnet" {
}

variable "location" {
}

variable "name" {
}

variable "address_space" {
  type = list(string)
}

variable "subscription_id" {
  type        = string
  description = "The ID of the subscription that you want to deploy the spoke to"
}

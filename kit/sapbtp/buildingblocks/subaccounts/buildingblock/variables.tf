variable "aws_account_id" {
  description = "this is for the tfstates Backend. in our case AWS."
  type        = string
}

variable "globalaccount" {
  type        = string
  description = "The subdomain of the global account in which you want to manage resources."
}

variable "region" {
  type        = string
  default     = "cf-eu30"
  description = "The region of the subaccount."
}

variable "workspace" {
  type        = string
  description = "The meshStack workspace identifier."
}

variable "project" {
  type        = string
  description = "The meshStack project identifier."
}

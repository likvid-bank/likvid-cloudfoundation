variable "parent_ou_name" {
  type        = string
  nullable    = false
  description = <<EOF
    Create a OU of the specified name and treat it as the root of all resources managed as part of this kit.
    This is good for separation, in particular if you don't have exclusive control over the AWS organization because
    it is supporting non-cloudfoundation workloads as well.
  EOF
}

variable "management_account_email" {
  type        = string
  nullable    = false
  description = "root user email for the management aws account"
}

variable "network_management_account_email" {
  type        = string
  nullable    = false
  description = "root user email for the network management aws account"
}

variable "automation_account_email" {
  type        = string
  nullable    = false
  description = "root user email for the automation aws account"
}

variable "meshstack_account_email" {
  type        = string
  nullable    = false
  description = "root user email for the meshstack aws account"
}

variable "admin_users" {
  type        = list(string)
  description = "list of emails of admin users"
}

variable "management_account_id" {
  type        = string
  description = "The id of your AWS Organization's root account"
}

variable "tf_backend_account_id" {
  type        = string
  description = "The id of the management account"
}

variable "networking_account_id" {
  type        = string
  description = "The id of the management account"
}

variable "parent_ou_id" {
  type        = string
  description = "Id of the parent OU used for all accounts in this platform"
}

variable "validation_role_name" {
  type        = string
  description = "Name of the validation/audit role to deploy as part of the baseline into every account managed by this platform"
}

variable "platform_engineers_group" {
  type = object({
    name    = string
    members = set(string)
  })
}

variable "foundation" {
  type        = string
  description = "name of the foundation"
}

variable "github_repo_full_name" {
  type        = string
  description = "Full name of the GitHub repo incl. owner e.g"
}

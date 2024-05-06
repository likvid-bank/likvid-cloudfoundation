variable "key_vault" {
  type        = object({
    name                = string
    resource_group_name = string
  })
  description = "Key Vault configuration"
}

variable "repo_name" {
  type = string
  default = "github-repo"
  description = "Name of the GitHub repository"
}

variable "github_token_secret_name" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "create_new" {
  type = bool
}

variable "description" {
  type    = string
  default = "created by github-repo-building-block"
}

variable "visibility" {
  type    = string
  default = "private"
}

variable "use_template" {
  type = bool
  description = "Set it to 'True' if you want to create a repo based on a Template Repository"
  default = false
}
variable "template_owner" {
  type = string
}

variable "template_repo" {
  type = string
  default = "github-repo"
}

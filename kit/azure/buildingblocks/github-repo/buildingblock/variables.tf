variable "key_vault" {
  type = object({
    name                = string
    resource_group_name = string
  })
  description = "Key Vault configuration"
}

variable "repo_name" {
  type        = string
  default     = "github-repo"
  description = "Name of the GitHub repository"
}

variable "github_token_secret_name" {
  type        = string
  description = "Name of the secret in Key Vault that holds the GitHub token"
}

variable "github_org" {
  type        = string
  description = "Name of the GitHub organization"
}

variable "create_new" {
  type        = bool
  description = "Flag to indicate whether to create a new repository"
}

variable "description" {
  type        = string
  default     = "created by github-repo-building-block"
  description = "Description of the GitHub repository"
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Visibility of the GitHub repository"
}

variable "use_template" {
  type        = bool
  description = "Flag to indicate whether to create a repo based on a Template Repository"
  default     = false
}

variable "template_owner" {
  type        = string
  description = "Owner of the template repository"
}

variable "template_repo" {
  type        = string
  default     = "github-repo"
  description = "Name of the template repository"
}

variable "github_app_id" {
  type        = string
  description = "ID of the GitHub App"
}

variable "github_app_installation_id" {
  type        = string
  description = "Installation ID of the GitHub App"
}

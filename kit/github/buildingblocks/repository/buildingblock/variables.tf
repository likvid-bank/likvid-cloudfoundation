variable "github_app_id" {
  type        = string
  description = "ID of the GitHub App"
}

variable "github_app_installation_id" {
  type        = string
  description = "Installation ID of the GitHub App"
}

variable "github_app_pem_file" {
  type        = string
  description = "GitHub App private key content"
}

variable "github_org" {
  type        = string
  description = "Name of the GitHub organization"
}

variable "repo_description" {
  type        = string
  default     = "created by github-repo-building-block"
  description = "Description of the GitHub repository"
}

variable "repo_name" {
  type        = string
  default     = "github-repo"
  description = "Name of the GitHub repository"
}

variable "repo_visibility" {
  type        = string
  default     = "private"
  description = "Visibility of the GitHub repository"
}

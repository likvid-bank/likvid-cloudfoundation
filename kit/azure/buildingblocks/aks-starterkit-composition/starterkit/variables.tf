variable "workspace_identifier" {
  type = string
}

variable "repo_name" {
  type        = string
  description = "Name of the repository to connect."
}

variable "name_prefix" {
  type        = string
  description = "prefix for name of the resources"
}

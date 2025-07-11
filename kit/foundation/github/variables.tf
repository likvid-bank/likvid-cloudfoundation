
variable "github_repo" {
  type        = string
  description = "name of the github repo"
}

variable "foundation" {
  type        = string
  description = "name of the foundation"
}

variable "actions_variables" {
  description = "github actions environment variables"
  type        = map(string)
}

variable "actions_secrets" {
  description = "github actions environment secrets"
  type        = map(string)
}

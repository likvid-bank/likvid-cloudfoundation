variable "repo_name" {
  type    = string
  default = "name of the created repository"
}

variable "description" {
  type    = string
  default = "created from a Likvid Bank DevOps Toolchain starter kit"
}

variable "visibility" {
  type    = string
  default = "private"
}

variable "template_owner" {
  type = string
}

variable "template_repo" {
  type = string
}
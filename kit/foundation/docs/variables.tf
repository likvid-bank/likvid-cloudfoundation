variable "module_docs" {
  description = "configures conventions for looking up remote_state of platform and foundation modules by prefix"
  type = list(object({
    prefix     = string
    key_prefix = optional(string)
    backend    = string
    config     = map(any)
  }))
}

variable "output_dir" {
  description = "path to the directory where to store the generated documentation output"
  type        = string
}

variable "template_dir" {
  description = "path to the directory containing the docs site template"
  type        = string
}

variable "foundation_dir" {
  description = "path to the collie foundation directory for this foundation"
  type        = string
}

variable "repo_dir" {
  description = "path to the collie repository directory"
  type        = string
}

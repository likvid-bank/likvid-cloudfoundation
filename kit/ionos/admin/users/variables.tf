variable "users" {
  type = list(object({
    email     = string
    firstname = string
    lastname  = string
  }))
}

variable "api_users" {
  type = list(object({
    email     = string
    firstname = string
    lastname  = string
  }))
}

variable "users" {
  type = list(object({
    email     = string
    firstname = string
    lastname  = string
  }))
}

variable "admin" {
  type = list(object({
    email     = string
    firstname = string
    lastname  = string
  }))
}

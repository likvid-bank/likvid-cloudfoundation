variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

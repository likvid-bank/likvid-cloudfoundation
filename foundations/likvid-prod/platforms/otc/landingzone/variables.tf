variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
  description = "Hub reference-architecture coordinates."
}

variable "otc_access_key" {
  type        = string
  sensitive   = true
  description = "Access key of an IAM user in the domain's `admin` group, which the architecture deploys with."
}

variable "otc_secret_key" {
  type        = string
  sensitive   = true
  description = "Secret key belonging to `otc_access_key`."
}

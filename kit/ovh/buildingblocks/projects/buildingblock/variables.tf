variable "workspace_id" {
  type        = string
  description = "Projects first block in name"
}

variable "project_id" {
  type        = string
  description = "Projects last block in name"
}

variable "ovh_account_id" {
  description = "OVH account ID for SAML URN construction"
  type        = string
}

variable "users" {
  type = list(object(
    {
      meshIdentifier = string
      username       = string
      firstName      = string
      lastName       = string
      email          = string
      euid           = string
      roles          = list(string)
    }
  ))
  description = "Users and their roles provided by meshStack (Note that users must exist in stackit)"
}

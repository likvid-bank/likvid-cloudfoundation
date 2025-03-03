variable "token" {
  description = "Token for Ionos API"
  type        = string
  sensitive   = true
}

variable "workspace_id" {
  type        = string
  description = "Virtual Data Center first block in name"
}

variable "project_id" {
  type        = string
  description = "Virtual Data Center last block in name"
}

# variable "dc_location" {
#   type        = string
#   default     = "de/fra"
#   description = "Virtual Data Center location, e.g. de/fra, de/txl, es/vit, fr/par, gb/lhr, us/ewr, us/las, us/mci"
# }

# variable "dc_description" {
#   type        = string
#   default     = "virtual data Center"
#   description = "Virtual Data Center description"
# }

variable "contract_id" {
  type        = string
  description = "contract number"
}

variable "aws_account_id" {
  description = "this is for the tfstates Backend. in our case AWS."
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
  description = "Users and their roles provided by meshStack (Note that users must exist in IONOS)"
}

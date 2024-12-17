variable "token" {
  description = "Authorization header"
  type        = string
}

variable "aws_account_id" {
  description = "this is for the tfstates Backend. in our case AWS."
  type        = string
}

variable "workspace_identifier" {
  type        = string
  description = "The meshStack workspace identifier."
}

variable "project_identifier" {
  type        = string
  description = "The meshStack project identifier."
}

# note: these permissions are passed in from meshStack and automatically updated whenever something changes
# atm. we are not using them inside this building block implementation, but they give us a trigger to often reconcile
# the permissions

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
  description = "Users and their roles provided by meshStack"
  # default = [
  #   {
  #     meshIdentifier = "mesh-123"
  #     username       = "jdoe"
  #     firstName      = "John"
  #     lastName       = "Doe"
  #     email          = "jdoe2@example.com"
  #     euid           = "euid-001"
  #     roles          = ["admin"]
  # }]
}

variable "reseller_reference" {
  description = "Reseller reference"
  type        = string
  default     = "33786094"
}

variable "ram_server_max" {
  description = "Maximum RAM for server"
  type        = number
  default     = 20480
}

variable "cpu_server_max" {
  description = "Maximum CPU for server"
  type        = number
  default     = 4
}

variable "hdd_volume_max_size" {
  description = "Maximum HDD volume size"
  type        = number
  default     = 614400
}

variable "ssd_volume_max_size" {
  description = "Maximum SSD volume size"
  type        = number
  default     = 614400
}

variable "ram_contract_max" {
  description = "Maximum RAM for contract"
  type        = number
  default     = 51200
}

variable "cpu_contract_max" {
  description = "Maximum CPU for contract"
  type        = number
  default     = 16
}

variable "hdd_volume_contract_max_size" {
  description = "Maximum HDD volume size for contract"
  type        = number
  default     = 614400
}

variable "ssd_volume_contract_max_size" {
  description = "Maximum SSD volume size for contract"
  type        = number
  default     = 614400
}

variable "ips" {
  description = "Number of IPs"
  type        = number
  default     = 1
}

variable "tgw_name" {
  type        = string
  description = "Name of the transit gateway"
}

variable "tgw_description" {
  type        = string
  description = "Description of the transit gateway"
  default     = null
}

variable "enable_auto_accept_shared_attachments" {
  type        = bool
  description = "Enable auto accept shared attachments"
  default     = true
}

variable "ram_allow_external_principals" {
  type        = bool
  description = "Allow external principals in RAM"
  default     = false
}

variable "ram_principals" {
  description = "A list of principals to share TGW with. Possible values are an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN"
  type        = list(string)
  default     = []
}

variable "ram_tags" {
  description = "Additional tags for the RAM"
  type        = map(string)
  default     = {}
}

variable "transit_gateway_cidr_blocks" {
  description = "List of CIDR blocks for the transit gateway"
  type        = list(string)
}

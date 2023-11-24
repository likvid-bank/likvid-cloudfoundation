
variable "parentManagementGroup" {
  default = "lv-foundation"
}

variable "landingzones" {
  default = "lv-landingzones"
}

variable "corp" {
  default = "lv-corp"
}

variable "online" {
  default = "lv-online"
}

variable "platform" {
  default = "lv-platform"
}

variable "connectivity" {
  default = "lv-connectivity"
}

variable "identity" {
  default = "lv-identity"
}

variable "management" {
  default = "lv-management"
}

variable "location" {
  type        = string
  description = "The Azure location where this policy assignment should exist, required when an Identity is assigned."
  default     = "germanywestcentral"
}
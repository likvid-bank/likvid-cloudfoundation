variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the OCI tenancy"
}

variable "foundation_compartment_ocid" {
  type        = string
  description = "The OCID of the foundation compartment"
}

variable "audit_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (minimum 90 for CIS compliance)"
  default     = 365
}

variable "enable_audit_log_forwarding" {
  type        = bool
  description = "Enable audit log event forwarding to streaming service"
  default     = false
}

variable "audit_log_stream_id" {
  type        = string
  description = "OCID of the stream to forward audit logs to (required if enable_audit_log_forwarding is true)"
  default     = null
}

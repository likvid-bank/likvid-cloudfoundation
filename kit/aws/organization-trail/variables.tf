variable "trail_name" {
  default = "org-cloudtrail"
}

variable "s3_bucket_name" {
  default = "org-cloudtrail-logs"
}

variable "auditors" {
  type        = list(string)
  default     = []
  description = "SSO user names (emails) that receive ReadOnlyAccess to the audit account for reviewing CloudTrail logs"
}

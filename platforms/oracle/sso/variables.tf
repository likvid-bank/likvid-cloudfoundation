variable "oci_region" {
  description = "OCI region"
  type        = string
}

variable "oci_identity_domain_id" {
  description = "OCI Identity Domain OCID"
  type        = string
}

variable "oci_compartment_id" {
  description = "OCI Compartment/Tenancy OCID for IAM policies"
  type        = string
}

variable "azure_ad_app_name" {
  description = "Display name for the Azure AD Enterprise Application"
  type        = string
  default     = "OCI Cloud SSO"
}

variable "azure_ad_admin_group_name" {
  description = "Azure AD group name for administrators"
  type        = string
}

variable "azure_ad_developer_group_name" {
  description = "Azure AD group name for developers"
  type        = string
}

variable "oci_admin_group_name" {
  description = "Name of the OCI administrators group"
  type        = string
  default     = "OCI-Administrators"
}

variable "oci_developer_group_name" {
  description = "Name of the OCI users/developers group"
  type        = string
  default     = "OCI-Users"
}

variable "organization_name" {
  description = "Organization name (used in resource naming)"
  type        = string
}

variable "create_oci_policies" {
  description = "Create IAM policies for federated users"
  type        = bool
  default     = true
}

variable "oci_policy_statements" {
  description = "OCI IAM policy statements for federated users"
  type        = list(string)
  default     = []
}

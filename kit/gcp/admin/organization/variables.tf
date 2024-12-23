variable "foundation" {
  type        = string
  description = "name of the foundation"
}

variable "foundation_project_id" {
  type        = string
  description = "Project ID of the GCP Project hosting foundation-level resources for this foundation"
}

variable "parent_folder_id" {
  type        = string
  description = <<EOF
    Folder id of the parent folder hosting this foundation.
    This is good for separation, in particular if you don't have exclusive control over the GCP organization because
    it is supporting non-cloudfoundation workloads as well.
  EOF
}

variable "domains_to_allow" {
  description = "The list of domains to allow users from. This list is concatenated to customer_ids_to_allow"
  type        = list(string)
}

variable "customer_ids_to_allow" {
  description = "The list of Google Customer Ids to allow users from."
  type = list(object(
    {
      domain      = string
      customer_id = string
    }
  ))
  default = []
}

variable "resource_locations_to_allow" {
  type        = list(string)
  description = "The list of resource locations to allow"
}

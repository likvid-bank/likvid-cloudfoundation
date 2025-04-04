locals {
  organization_id = google_project.foundation.org_id
}

data "google_organization" "orgs" {
  for_each = toset(var.domains_to_allow)
  domain   = each.value
}

data "google_folder" "parent" {
  folder = var.parent_folder_id
}

locals {
  resolved_customer_ids_to_allow = concat(
    [for org in data.google_organization.orgs : {
      customer_id = org["directory_customer_id"],
      domain      = org.domain
      }
    ],
    var.customer_ids_to_allow
  )
}
## root level policies

module "allowed-policy-member-domains" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 5.1.0"
  policy_for        = "folder"
  folder_id         = data.google_folder.parent.name
  constraint        = "constraints/iam.allowedPolicyMemberDomains"
  policy_type       = "list"
  allow             = local.resolved_customer_ids_to_allow[*].customer_id
  allow_list_length = length(local.resolved_customer_ids_to_allow)
}

module "allowed-policy-resource-locations" {
  source            = "terraform-google-modules/org-policy/google"
  version           = "~> 5.1.0"
  policy_for        = "folder"
  folder_id         = data.google_folder.parent.name
  constraint        = "constraints/gcp.resourceLocations"
  policy_type       = "list"
  allow             = var.resource_locations_to_allow
  allow_list_length = length(var.resource_locations_to_allow)
}

# admin folder

resource "google_folder" "admin" {
  display_name = "admin"
  parent       = data.google_folder.parent.name
}

# landing zone folders

resource "google_folder" "dev" {
  display_name = "likvid-dev"
  parent       = data.google_folder.parent.name
}

resource "google_folder" "prod" {
  display_name = "likvid-prod"
  parent       = data.google_folder.parent.name
}

resource "google_folder" "data_lagoon" {
  display_name = "Data Lagoon"
  parent       = data.google_folder.parent.name
}

# management project

resource "google_project" "foundation" {
  name       = "${var.foundation}-management"
  project_id = var.foundation_project_id
  folder_id  = google_folder.admin.folder_id

  // the project already exists, we merely want to update its folder
  lifecycle {
    ignore_changes = [billing_account]
  }
}

resource "google_service_account" "validation" {
  project      = var.foundation_project_id
  account_id   = "${var.foundation}-foundation-gha"
  display_name = "${var.foundation}-foundation-tf-validation-user"
  description  = "Used by the cloudfoundation team to validate the deployment from github actions"
}

## Permissions

locals {
  validation_roles = {
    organization = toset([
      "roles/iam.organizationRoleViewer",
      "roles/billing.viewer" # gives access to the billing account
    ])
    parent = toset([

      "roles/viewer",               // view project resources, deployed by the cloud foundation. Can potentially limit this
      "roles/iam.securityReviewer", # todo: test if we still need this when we have viewer

      "roles/browser",                          # required to get folder details, which are not granted by viewer role
      "roles/orgpolicy.policyViewer",           # required to view
      "roles/serviceusage.serviceUsageConsumer" # required to reconcile enabled services on a project
    ])
    billing_project = toset([
      "roles/viewer"
    ])
  }
}
# we need permissions to read roles on the org level


resource "google_organization_iam_member" "validation" {
  for_each = local.validation_roles.organization

  org_id = data.google_organization.parent_org.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.validation.email}"
}


resource "google_folder_iam_member" "validation" {
  for_each = local.validation_roles.parent

  folder = var.parent_folder_id
  role   = each.key
  member = "serviceAccount:${google_service_account.validation.email}"
}

resource "google_project_iam_member" "validation" {
  for_each = local.validation_roles.billing_project

  project = var.billing_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.validation.email}"
}


## Workload Identity Federation setup

resource "google_iam_workload_identity_pool" "github" {
  display_name              = "GitHub pool"
  workload_identity_pool_id = "github-pool"
  depends_on                = [google_project_service.enabled_services, google_project_iam_member.platform_engineers_wif]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_provider_id = "github-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  display_name                       = "GitHub provider"

  attribute_mapping = {
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "google.subject"             = "assertion.sub"
  }

  # restrict access to one specific repository
  # see https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token
  attribute_condition = "(assertion.repository == '${var.github_repo_full_name}')"

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_binding" "github" {
  service_account_id = google_service_account.validation.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo_full_name}"
  ]
}

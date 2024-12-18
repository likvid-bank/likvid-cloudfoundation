# Place your module's terraform resources, variables, outputs etc. here as usual.
# Note that you should typically not put a terraform{} block into cloud foundation kit modules,
# these will be provided by the platform implementations using this kit module.

data "google_project" "foundation" {
  project_id = var.foundation_project_id
}

data "google_folder" "parent" {
  folder              = var.parent_folder_id
  lookup_organization = true
}

// we may be hosting our IAM groups in a different org than the parent folder
data "google_organization" "groups_org" {
  domain = var.platform_engineers_group.domain
}

data "google_organization" "parent_org" {
  organization = data.google_folder.parent.organization
}

locals {
  # the foundation service account needs to deploy resources of various kinds
  # because it authenticates against the foundation project, we do unfortunately ahve
  # to list and enable all of these services here
  enabled_services = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "run.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudidentity.googleapis.com"
  ])
}


resource "google_project_service" "enabled_services" {
  project            = var.foundation_project_id
  for_each           = local.enabled_services
  service            = each.key
  disable_on_destroy = false
}

# Cloud Foundation Admin Permission setup

# created manually via `gcloud identity groups create "likvid-foundation-platform-engineers@meshcloud.io" --organization "meshcloud.io"`
data "google_cloud_identity_group_lookup" "platform_engineers" {
  group_key {
    id = "${var.platform_engineers_group.name}@${data.google_organization.groups_org.domain}"
  }
}

resource "google_cloud_identity_group_membership" "platform_engineers" {
  for_each = var.platform_engineers_group.members
  group    = data.google_cloud_identity_group_lookup.platform_engineers.name

  preferred_member_key {
    id = each.key
  }

  roles {
    name = "MEMBER"
  }
}

locals {
  platform_engineers_group_emailid = "group:${data.google_cloud_identity_group_lookup.platform_engineers.group_key[0].id}"
}

## Org Wide Permissions

# relevant permissions in the policyAdmin role are only available via the built-in role and cannot be assigned to custom
# roles, so we have to use the built-in one here. This role can only be assigned on org level (folder not supported).
resource "google_organization_iam_member" "cloudfoundation_deploy_org_policy_admin" {
  org_id = data.google_organization.parent_org.org_id
  role   = "roles/orgpolicy.policyAdmin"
  member = local.platform_engineers_group_emailid
}

resource "google_organization_iam_member" "cloudfoundation_deploy_org_role_admin" {
  org_id = data.google_organization.parent_org.org_id
  role   = "roles/iam.organizationRoleAdmin"
  member = local.platform_engineers_group_emailid
}

## Platform Level (parent folder) permissions

# standard roles to assign
locals {
  platform_engineer_roles = toset([
    # all of these roles are assignable at folder/project scope
    # see https://cloud.google.com/iam/docs/understanding-roles#organization-policy-roles for reference

    "roles/browser",
    "roles/iam.serviceAccountViewer",
    "roles/iam.securityAdmin",
    "roles/resourcemanager.organizationAdmin", # todo: this could possibly be scoped a little more finegrained

    # TODO: these should go into a separate security kit module (equivalent to azure/logging)
    # but that requires a separate refactoring
    "roles/securitycenter.admin",
    "roles/cloudasset.owner"
  ])
}

resource "google_folder_iam_member" "platform_engineers" {
  for_each = local.platform_engineer_roles
  folder   = data.google_folder.parent.folder_id
  role     = each.key
  member   = local.platform_engineers_group_emailid
}


resource "google_organization_iam_custom_role" "cloudfoundation_deploy" {
  role_id     = replace(var.platform_engineers_group.name, "-", "_")
  org_id      = data.google_organization.parent_org.org_id
  title       = var.platform_engineers_group.name
  description = "Permissions required to deploy the cloud foundation"
  permissions = [
    "resourcemanager.organizations.get",

    "resourcemanager.organizations.getIamPolicy",
    "resourcemanager.organizations.setIamPolicy",

    "resourcemanager.folders.get",
    "resourcemanager.folders.list",
    "resourcemanager.folders.create",
    "resourcemanager.folders.delete",
    "resourcemanager.folders.update",
    "resourcemanager.folders.move",

    "resourcemanager.folders.getIamPolicy",
    "resourcemanager.folders.setIamPolicy",

    "resourcemanager.projects.create",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.list",
    "resourcemanager.projects.move",
    "resourcemanager.projects.setIamPolicy",
    "resourcemanager.projects.update",

    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.list",
    "iam.roles.undelete",
    "iam.roles.update",

    "iam.serviceAccounts.get",

    "serviceusage.services.enable",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.use",

    # Storage bucket creation permissions, used when this service account should deploy a bucket and give access to other SAs.
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.delete",

    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "storage.buckets.getIamPolicy",
    "storage.buckets.setIamPolicy",


    "billing.accounts.get",
    "billing.accounts.list",
    "billing.accounts.getIamPolicy",
    "billing.accounts.setIamPolicy",
    "billing.accounts.getUsageExportSpec",
    "billing.accounts.updateUsageExportSpec",
    "billing.resourceAssociations.list",
    "billing.resourceAssociations.create"
  ]
}

resource "google_folder_iam_member" "cloudfoundation_deploy" {
  folder = data.google_folder.parent.id
  role   = google_organization_iam_custom_role.cloudfoundation_deploy.id
  member = local.platform_engineers_group_emailid
}

## Foundation project permissions

resource "google_project_iam_member" "platform_engineers" {
  project = data.google_project.foundation.project_id
  role    = "roles/editor" # todo: this could possibly be scoped a little more finegrained
  member  = local.platform_engineers_group_emailid
}

resource "google_project_iam_member" "platform_engineers_wif" {
  project = data.google_project.foundation.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = local.platform_engineers_group_emailid
}

resource "google_project_iam_member" "platform_engineers_saadmin" {
  project = data.google_project.foundation.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = local.platform_engineers_group_emailid
}

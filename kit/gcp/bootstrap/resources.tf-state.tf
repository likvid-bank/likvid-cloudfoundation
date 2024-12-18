
resource "google_storage_bucket" "terraform_state" {
  project                     = var.foundation_project_id
  name                        = var.tf_state_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true

  # this bucket holds a lot of important state, prevent accidentally destorying it
  force_destroy = false

  # set storage.publicAccessPrevention when that ships as part of the official google provider
  # as of 07/22 it's only available in the google-beta provider

  versioning {
    enabled = true
  }
}

locals {
  all_members_map = {
    platform_engineers = local.platform_engineers_group_emailid,
    service_account    = "serviceAccount:${google_service_account.validation.email}"
  }
}

# cloud foundation team members need to be able to find the project in resource hierarchy/gcloud/gsutil
resource "google_project_iam_member" "project_browser" {
  for_each = local.all_members_map
  project  = var.foundation_project_id
  role     = "roles/browser"
  member   = each.value
}

# cloud foundation team members need to able to find the bucket in resource hierarchy/gcloud/gsutil
resource "google_project_iam_custom_role" "storage_metadata_viewer" {
  project     = var.foundation_project_id
  title       = "storage metadata viewer"
  description = "allow reading storage bucket and object metadata"
  role_id     = "storage_metadata_viewer"
  permissions = [
    "storage.objects.list",
    "storage.buckets.get",
    "storage.buckets.list"
  ]
}

locals {
  bucket_resource_name = "projects/_/buckets/${google_storage_bucket.terraform_state.name}"
}

data "google_iam_policy" "terraform_state" {
  # the list permission cannot be scoped to a prefix, so users will always be able to list all bucket contents
  # that poses no harm for the terraform states however, since users will normally have access to the git repo of all
  # terraform code anyway, we only want to restrict the subset of states they can actually read and modify
  binding {
    role    = google_project_iam_custom_role.storage_metadata_viewer.id
    members = toset([local.all_members_map.platform_engineers, local.all_members_map.service_account])
  }

  binding {
    role    = "roles/storage.admin"
    members = [local.platform_engineers_group_emailid]
  }

  # Add a permission for the gh actions reader to read all terraform state.
  # This is what it needs in order to run terraform plan for drift detection.
  # One issue here is that the "reader" has access to the foundation-deploy keys from the bootstrap phase
  # so this user could technically also run terraform apply.
  #
  # This won't be a problem anymore once we adopted "SPN-less bootstrap" modules like we have already developed
  # for Azure. For the time being, we assume that risk
  dynamic "binding" {
    for_each = var.github_repo_enable_tf_state_access ? [1] : []

    content {
      role    = "roles/storage.objectViewer"
      members = ["serviceAccount:${google_service_account.validation.email}"]
    }
  }
}

resource "google_storage_bucket_iam_policy" "terraform_state" {
  bucket      = google_storage_bucket.terraform_state.name
  policy_data = data.google_iam_policy.terraform_state.policy_data
}

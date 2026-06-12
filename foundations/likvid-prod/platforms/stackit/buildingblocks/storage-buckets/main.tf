variable "ci_service_account_email" {
  description = "Email of the CI service account that needs owner access on the storage-buckets project to run plan/apply"
  type        = string
}

variable "hub" {
  description = "Hub building-block coordinates (single source of truth in hub.hcl, passed in by terragrunt)"
  type = object({
    module    = string
    git_ref   = string
    bbd_draft = bool
  })
}

locals {
  meshstack = {
    owning_workspace_identifier = "devops-platform"
  }
}

resource "meshstack_project" "stackit_storage_buckets" {
  metadata = {
    owned_by_workspace = local.meshstack.owning_workspace_identifier
    name               = "stackit-storage-buckets"
    display_name       = "STACKIT Storage Buckets"
  }
  spec = {
    display_name              = "STACKIT Storage Buckets"
    payment_method_identifier = "devops-platform-budget"
    tags = {
      Schutzbedarf         = ["public"]
      environment          = ["prod"]
      projectOwner         = ["Anna Admin"]
      LandingZoneClearance = ["cloud-native"]
    }
  }
}

# FIXME: It's not possible to create custom platform tenants with required user inputs
# Created via panel and then imported.
resource "meshstack_tenant_v4" "stackit_storage_buckets" {
  metadata = {
    owned_by_workspace = local.meshstack.owning_workspace_identifier
    owned_by_project   = meshstack_project.stackit_storage_buckets.metadata.name
  }

  spec = {
    platform_identifier     = "stackit.sovereign"
    landing_zone_identifier = "stackit-prod"
  }
}

resource "stackit_authorization_project_role_assignment" "ci_sa" {
  resource_id = meshstack_tenant_v4.stackit_storage_buckets.spec.platform_tenant_id
  role        = "owner"
  subject     = var.ci_service_account_email
}

module "stackit_storage_bucket_bb" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/${var.hub.module}?ref=${var.hub.git_ref}"

  hub                = var.hub
  stackit_project_id = meshstack_tenant_v4.stackit_storage_buckets.spec.platform_tenant_id
  meshstack          = local.meshstack
}

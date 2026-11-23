# The shared PostgreSQL instances of the SKE platform and the "Postgres DB" definition that gives a
# namespace a database on them. The platform federates both definitions with its service account.

locals {
  owning_workspace_identifier = "devops-platform"
  runner_ref                  = { kind = "meshBuildingBlockRunner", uuid = "98520496-627d-43e6-82da-ce499179ff3f" }

  # The STACKIT Project block grants project admins `owner`, which the apply's STACKIT login needs to
  # grant the service account its role.
  project_admins = ["agrub@meshcloud.io"]
}

data "meshstack_tenant" "platform" {
  metadata = {
    owned_by_workspace  = local.owning_workspace_identifier
    owned_by_project    = "stackit-kubernetes-platform"
    platform_identifier = "likvid-stackit.global"
  }
}

data "meshstack_building_blocks" "automation_identity" {
  tenant_uuid = data.meshstack_tenant.platform.metadata.uuid
  name        = "Automation Identity"
}

data "meshstack_building_blocks" "cluster" {
  tenant_uuid = data.meshstack_tenant.platform.metadata.uuid
  name        = "SKE Cluster"
}

# Registered by the STACKIT Landing Zone in ../../stackit/landingzone, owned by stackit-platform.
data "meshstack_building_block_definition" "stackit_project" {
  metadata = { uuid = "50bec1ee-5e35-41fa-b808-d5c9e8e435f5" }
}

data "meshstack_platforms" "stackit" {
  identifier = "likvid-stackit.global"
}

data "meshstack_platforms" "ske_namespace" {
  identifier = "ske-namespace.sovereign"
}

locals {
  service_account_email         = jsondecode(one(data.meshstack_building_blocks.automation_identity.building_blocks).status.outputs["service_account_email"].value)
  cluster_egress_address_ranges = jsondecode(jsondecode(one(data.meshstack_building_blocks.cluster.building_blocks).status.outputs["egress_address_ranges"].value))
  ske_cluster_name              = jsondecode(one(data.meshstack_building_blocks.cluster.building_blocks).status.outputs["cluster_name"].value)
  platform_stackit_project_id   = data.meshstack_tenant.platform.spec.platform_tenant_id
  stackit_project_id            = jsondecode(meshstack_building_block.stackit_project.status.outputs["project_id"].value)
}

resource "meshstack_project" "this" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    name               = "shared-postgres"
  }

  spec = {
    display_name              = "Shared PostgreSQL"
    payment_method_identifier = "devops-platform-budget"
    # The namespace tenant's landing zone ske-namespace-prod only admits these values.
    tags = {
      projectOwner         = ["Andreas Grub (agrub@meshcloud.io)"]
      environment          = ["prod"]
      Schutzbedarf         = ["public"]
      LandingZoneClearance = ["cloud-native"]
      ResponsibilityLevel  = ["Cloud Pro"]
    }
  }
}

resource "meshstack_project_user_binding" "admin" {
  for_each = toset(local.project_admins)

  metadata = { name = "shared-postgres-admin-${substr(sha256(each.key), 0, 12)}" }
  role_ref = { name = "Project Admin" }
  target_ref = {
    owned_by_workspace = meshstack_project.this.metadata.owned_by_workspace
    name               = meshstack_project.this.metadata.name
  }
  subject = { name = each.key }
}

# Destroying it deletes the STACKIT project with the shared instances and all databases.
resource "meshstack_tenant" "stackit" {
  lifecycle {
    prevent_destroy = true
  }

  # The tenant gets its Platform Tenant ID from the STACKIT Project block below.
  wait_for_completion = false

  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.stackit.platforms).ref
    landing_zone_ref = { name = "likvid-stackit-default" }
  }
}

resource "meshstack_building_block" "stackit_project" {
  # Its run reads the project's members, so the admins have to be members first.
  depends_on = [meshstack_project_user_binding.admin]

  wait_for_completion = true

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [spec.building_block_definition_version_ref]

    postcondition {
      condition     = self.status.succeeded
      error_message = "Building block ${self.metadata.uuid} did not succeed: health status ${self.status.health_status}, action ${self.status.action}. See its run in meshPanel."
    }
  }

  spec = {
    building_block_definition_version_ref = data.meshstack_building_block_definition.stackit_project.version_latest_release
    display_name                          = "STACKIT Project"
    target_ref                            = meshstack_tenant.stackit.ref
    inputs                                = {}
  }
}

resource "stackit_authorization_project_role_assignment" "platform" {
  resource_id = local.stackit_project_id
  role        = "postgres-flex.admin"
  subject     = local.service_account_email
}

# The connector's Jobs run here, outside the quota of the app teams' namespaces.
resource "meshstack_tenant" "jobs" {
  metadata = {
    owned_by_workspace = local.owning_workspace_identifier
    owned_by_project   = meshstack_project.this.metadata.name
  }

  spec = {
    platform_ref     = one(data.meshstack_platforms.ske_namespace.platforms).ref
    landing_zone_ref = { name = "ske-namespace-prod" }
  }
}

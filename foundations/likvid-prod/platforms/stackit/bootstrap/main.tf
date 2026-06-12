resource "stackit_resourcemanager_project" "management" {
  parent_container_id = var.organization_id
  name                = "likvid-cloudfoundation-management"
  owner_email         = "jrudolph@meshcloud.io"
}

# State-only removal: null_resources replaced by restapi_object below.
# destroy = false prevents the old destroy provisioners from running during migration.
removed {
  from = null_resource.platform_admin
  lifecycle { destroy = false }
}

removed {
  from = null_resource.platform_users
  lifecycle { destroy = false }
}

ephemeral "stackit_access_token" "token" {}

provider "restapi" {
  alias = "stackit_authorization"
  uri   = var.api_url
  headers = {
    Authorization = "Bearer ${ephemeral.stackit_access_token.token.access_token}"
    Content-Type  = "application/json"
  }
  write_returns_object = false
}

locals {
  organization_members = merge(
    { for m in var.platform_admins : "${m.subject}/${m.role}" => m },
    { for m in var.platform_users : "${m.subject}/${m.role}" => m }
  )
}

resource "restapi_object" "organization_member" {
  for_each = local.organization_members
  provider = restapi.stackit_authorization

  path         = "/v2/${var.organization_id}/members"
  create_path  = "/v2/${var.organization_id}/members"
  read_path    = "/v2/${var.organization_id}/members"
  destroy_path = "/v2/${var.organization_id}/members/remove"

  create_method  = "PATCH"
  read_method    = "GET"
  update_method  = "PATCH"
  destroy_method = "POST"

  object_id    = each.value.subject
  id_attribute = "subject"

  data = jsonencode({
    members      = [{ subject = each.value.subject, role = each.value.role }]
    resourceType = "organization"
  })

  destroy_data = jsonencode({
    forceRemove  = true
    members      = [{ subject = each.value.subject, role = each.value.role }]
    resourceType = "organization"
  })

  read_search = {
    search_key   = "subject"
    search_value = each.value.subject
    results_key  = "members"
  }

  ignore_server_additions = true
}

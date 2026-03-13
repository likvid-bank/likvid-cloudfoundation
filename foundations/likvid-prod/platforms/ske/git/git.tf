variable "stackit_project_id" {
  description = "STACKIT project UUID"
  type        = string
}

variable "forgejo_organization" {
  description = "Forgejo organization that should exist in the STACKIT Git instance"
  type        = string
  default     = "likvid"
}

resource "stackit_git" "git" {
  project_id = var.stackit_project_id
  name       = "likvid"
  # Note: That should probably be randomized for meshTrial as all STACKIT git instances need a globally unique name, see URL 'likvid.git.onstackit.cloud'
}

# this direct input to output mapping looks funny, but reflects the manual step when bootstrapping a stackit_git instance
# which requires creating a Personal Access Token for a Bot Account (shared platform engineering account)
# At least we can use it here to create the Org within the (shared) Forgejo Instance
variable "forgejo_token" {
  type      = string
  sensitive = true
}

provider "restapi" {
  uri                  = stackit_git.git.url
  write_returns_object = true

  headers = {
    Authorization = "token ${var.forgejo_token}"
    Content-Type  = "application/json"
  }
}

# Using the gitea provider is brittle: Org Create works, but refreshing plan fails with weird 403 against STACKIT Git,
# so fallback to simple REST API resource
resource "restapi_object" "forgejo_organization" {
  path          = "/api/v1/orgs"
  id_attribute  = "username"
  object_id     = var.forgejo_organization
  update_method = "PATCH"
  data = jsonencode({
    username   = var.forgejo_organization
    visibility = "private"
  })
  force_new = ["data"]
  debug     = true
}

import {
  to = restapi_object.forgejo_organization
  id = "/api/v1/orgs/${var.forgejo_organization}"
}

output "forgejo_token" {
  value     = var.forgejo_token
  sensitive = true
}

output "forgejo_base_url" {
  value = stackit_git.git.url
}

output "forgejo_organization" {
  value = jsondecode(restapi_object.forgejo_organization.api_response).name
}

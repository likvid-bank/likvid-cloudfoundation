variable "meshstack" {
  type = object({
    owning_workspace_identifier = string
  })
}

variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "github" {
  type = object({
    org                 = string
    app_id              = string
    app_installation_id = string
    app_pem_file        = string
  })
  sensitive = true
}

variable "platform_ref" {
  type = object({
    uuid = string
    kind = optional(string, "meshPlatform")
  })
  description = "Reference to the meshPlatform the starter kit creates its tenants on."
}

variable "landing_zone_refs" {
  type        = map(object({ name = string, kind = optional(string, "meshLandingZone") }))
  description = "References to the meshLandingZones, keyed by stage."
}

variable "openshift" {
  type = object({
    api_server_url = string
    apps_domain    = string
    registry_host  = string
  })
}

variable "github_repo_definition" {
  type = object({
    uuid         = string
    version_uuid = string
  })
  description = "Released `github/repository` definition shared with the AKS starter kit, so other workspaces may order it."
}

variable "github_template_repo_path" {
  type = string
}

variable "github_workflow_filename" {
  type = string
}

variable "project_tags" {
  type = object({
    stages = map(map(list(string)))
  })
}

module "connector" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/openshift/github-connector?ref=${var.hub.git_ref}"

  meshstack = var.meshstack
  hub       = var.hub

  openshift_api_server_url = var.openshift.api_server_url
  openshift_registry_host  = var.openshift.registry_host

  github_org                  = var.github.org
  github_app_id               = var.github.app_id
  github_app_installation_id  = var.github.app_installation_id
  github_app_pem_file         = var.github.app_pem_file
  github_repo_definition_uuid = var.github_repo_definition.uuid
  github_workflow_filename    = var.github_workflow_filename

  notification_subscribers = []
}

module "starterkit" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/openshift/starterkit?ref=${var.hub.git_ref}"

  meshstack = var.meshstack
  hub       = var.hub

  platform_ref      = var.platform_ref
  landing_zone_refs = var.landing_zone_refs

  building_block_definition_version_refs = {
    "git-repository" : { uuid = var.github_repo_definition.version_uuid }
    "github-actions-connector" : module.connector.building_block_definition.version_ref
  }

  github_org                = var.github.org
  github_template_repo_path = var.github_template_repo_path
  openshift_apps_domain     = var.openshift.apps_domain

  project_tags             = var.project_tags
  notification_subscribers = []
}

output "building_block_definition" {
  description = "BBD identity of the OpenShift starter kit."
  value       = module.starterkit.building_block_definition
}

output "owning_workspace" {
  description = "Workspace that owns the starter kit BBD; required to order it while draft."
  value       = var.meshstack.owning_workspace_identifier
}

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

variable "connector_config_tf" {
  description = "Raw config.tf from connector/backplane output."
  type        = string
  sensitive   = true
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
  description = "References to the meshLandingZones for dev and prod, keyed by stage."
}

variable "github_template_repo_path" {
  type = string
}

variable "apps_base_domain" {
  type = string
}

variable "project_tags" {
  type = object({
    dev  = map(list(string))
    prod = map(list(string))
  })
}

module "github_repo" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/github/repository?ref=${var.hub.git_ref}"

  meshstack = var.meshstack
  hub       = var.hub

  github = var.github

  notification_subscribers = []
}

module "connector" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/github-connector?ref=${var.hub.git_ref}"

  meshstack = var.meshstack
  hub       = var.hub

  github = {
    repo_definition_uuid = module.github_repo.building_block_definition.uuid
    org                  = var.github.org
    app_id               = var.github.app_id
    app_installation_id  = var.github.app_installation_id
    app_pem_file         = var.github.app_pem_file
  }

  aks = {
    connector_config_tf_base64 = base64encode(var.connector_config_tf)
  }

  notification_subscribers = []
}

module "starterkit" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/aks/starterkit?ref=${var.hub.git_ref}"

  meshstack = var.meshstack
  hub       = var.hub

  platform_ref      = var.platform_ref
  landing_zone_refs = var.landing_zone_refs

  building_block_definition_version_refs = {
    "git-repository" : module.github_repo.building_block_definition.version_ref
    "github-actions-connector" : module.connector.building_block_definition.version_ref
  }

  github_org                = var.github.org
  github_template_repo_path = var.github_template_repo_path
  apps_base_domain          = var.apps_base_domain

  project_tags             = var.project_tags
  notification_subscribers = []
}

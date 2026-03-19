variable "meshstack" {
  type = object({
    owning_workspace_identifier = string
    required_project_tags       = map(list(string))
  })
}

variable "hub" {
  type = object({
    git_ref   = string
    bbd_draft = bool
  })
}

variable "full_platform_identifier" {
  type = string
}

variable "landing_zone_identifiers" {
  type = object({
    dev  = string
    prod = string
  })
  description = "Identifiers of meshLandingZones for dev and prod."
}

variable "kubeconfig" {
  type      = any
  sensitive = true
}

variable "forgejo_token" {
  type      = string
  sensitive = true
}

variable "forgejo_organization" {
  type = string
}

variable "forgejo_base_url" {
  type = string
}

variable "stackit_harbor_project" {
  type = string
}

variable "stackit_harbor_push_robot_user" {
  type = string
}

variable "stackit_harbor_push_robot_password" {
  type      = string
  sensitive = true
}

variable "stackit_harbor_pull_robot_user" {
  type = string
}

variable "stackit_harbor_pull_robot_password" {
  type      = string
  sensitive = true
}

variable "stackit_project_id" {
  type = string
}

variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "dns_zone_name" {
  type = string
}

variable "add_random_name_suffix" {
  type = bool
}

variable "template_name" {
  type = string
}

variable "template_repo_clone_url" {
  type = string
}

locals {
  stackit_harbor_registry = "registry.onstackit.cloud" # hard-coded for all container images in STACKIT
}

module "starterkit" {
  source = "../../../../../../meshstack-hub/modules/ske/ske-starterkit" # TODO replace with URL and ?ref=${var.hub.git_ref}

  meshstack = var.meshstack
  hub       = var.hub

  building_block_definitions = {
    "git-repository" : module.git_repository.building_block_definition
    "forgejo-connector" : module.forgejo_connector.building_block_definition
  }

  full_platform_identifier = var.full_platform_identifier
  landing_zone_identifiers = var.landing_zone_identifiers
  project_tags = {
    owner_tag_key = "projectOwner" # tag value is the creator of the starter kit building block
    dev = merge(var.meshstack.required_project_tags, {
      "environment"  = ["dev"]
      "Schutzbedarf" = ["internal"] # overwrites default
    })
    prod = merge(var.meshstack.required_project_tags, {
      "environment" = ["prod"]
    })
  }

  repo_clone_addr        = var.template_repo_clone_url
  dns_zone_name          = var.dns_zone_name
  add_random_name_suffix = var.add_random_name_suffix
}

module "git_repository" {
  source = "../../../../../../meshstack-hub/modules/stackit/git-repository" # TODO replace with URL and ?ref=${var.hub.git_ref}

  meshstack = var.meshstack
  hub       = var.hub

  forgejo_token        = var.forgejo_token
  forgejo_organization = var.forgejo_organization
  forgejo_base_url     = var.forgejo_base_url

  action_secrets = {
    HARBOR_USERNAME = var.stackit_harbor_push_robot_user
    HARBOR_PASSWORD = var.stackit_harbor_push_robot_password
  }

  action_variables = {
    HARBOR_REGISTRY = local.stackit_harbor_registry
    HARBOR_PROJECT  = var.stackit_harbor_project
    APP_NAME        = var.template_name
  }

  stackit_project_id          = var.stackit_project_id
  stackit_service_account_key = var.stackit_service_account_key
}

module "forgejo_connector" {
  source = "../../../../../../meshstack-hub/modules/ske/forgejo-connector" # TODO replace with URL and ?ref=${var.hub.git_ref}

  meshstack = var.meshstack
  hub       = var.hub

  kubeconfig = var.kubeconfig

  forgejo_host                 = var.forgejo_base_url
  forgejo_api_token            = var.forgejo_token
  forgejo_repo_definition_uuid = module.git_repository.building_block_definition.uuid

  harbor_host     = local.stackit_harbor_registry
  harbor_username = var.stackit_harbor_pull_robot_user
  harbor_password = var.stackit_harbor_pull_robot_password

  additional_kubernetes_secrets = local.ai_kubernetes_secrets
}


moved {
  from = module.backplane.module.git_repository.meshstack_building_block_definition.this
  to   = module.git_repository.meshstack_building_block_definition.this
}

moved {
  from = meshstack_building_block_definition.this
  to   = module.starterkit.meshstack_building_block_definition.this
}

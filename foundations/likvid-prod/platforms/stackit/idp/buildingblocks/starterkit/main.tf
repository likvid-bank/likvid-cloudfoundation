terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.3"
    }
  }
}

variable "owned_by_workspace" {
  description = "The meshstack workspace that owns this building block definition"
  type        = string
}

variable "full_platform_identifier" {
  description = "The meshstack platform identifier – sourced from idp/platform outputs"
  type        = string
}

variable "landing_zone_dev_identifier" {
  description = "The meshstack landing zone identifier for dev – sourced from idp/platform outputs"
  type        = string
}

variable "landing_zone_prod_identifier" {
  description = "The meshstack landing zone identifier for prod – sourced from idp/platform outputs"
  type        = string
}

locals {
  git_ref = "main"
}

module "ske_starterkit" {
  source                = "git::https://github.com/meshcloud/meshstack-hub.git//modules/ske/ske-starterkit?ref=${local.git_ref}"
  meshstack_hub_git_ref = local.git_ref

  owned_by_workspace           = var.owned_by_workspace
  full_platform_identifier     = var.full_platform_identifier
  landing_zone_dev_identifier  = var.landing_zone_dev_identifier
  landing_zone_prod_identifier = var.landing_zone_prod_identifier
  icon                         = "https://raw.githubusercontent.com/meshcloud/meshstack-hub/${local.git_ref}/modules/ske/ske-starterkit/buildingblock/logo.png"
}

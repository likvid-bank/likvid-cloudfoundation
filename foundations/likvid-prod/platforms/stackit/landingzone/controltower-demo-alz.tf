# Application Landing Zones for the STACKIT Control Tower demo.
#
# Each definition hands a team a whole workspace in one order — payment method, project and a STACKIT
# tenant on a landing zone this unit already deploys — so the demo can tell its story one level above
# a single project. Everything in this file belongs to that demo and can be removed with it; the
# platform, the two landing zones and the project starterkit in main.tf are untouched.
#
# Owned by `stackitcontrolto`, not by the platform workspace: the demo portal authenticates as that
# workspace, and a definition it cannot see is a definition it cannot order.

locals {
  # The workspace starterkit does not exist at the architecture's `hub.git_ref`, so this file pins its
  # own commit. Used in the module source too, which OpenTofu evaluates statically.
  controltower_demo_hub_git_ref = "87a324c0bc9f389e68a611c6ed81cfea1a7139b8"

  # meshStack instances cap workspace identifiers at 16 characters, which the module default (63)
  # does not know about, and the demo wants dash-separated lowercase names. Both frontends compile
  # this with the JavaScript RegExp engine, so the lookahead that caps the length is honoured.
  controltower_demo_workspace_identifier_pattern = "^(?=.{1,16}$)([a-z0-9]+-)*[a-z0-9]+$"

  # meshStack drops any tag whose key has no definition on the instance, so these maps carry only keys
  # that exist there. Four `meshProject` tags are mandatory, as is `meshPaymentMethod.paymentMethodType`.
  controltower_demo_tags = {
    workspace = {
      SecurityContact = ["stackit@meshcloud.io"]
      BusinessUnit    = ["IT"]

      # The panel-managed `Workspace-Project` policy intersects this with `meshProject.environment`,
      # which is `dev` below. Without `dev` here every project creation in the new workspace is a 403.
      environment = ["dev", "prod"]
    }

    payment_method = {
      # `internal` rather than `costCenter`, which asks for a four-digit cost center number no demo has.
      paymentMethodType = ["internal"]
    }

    project = {
      projectOwner = ["stackit@meshcloud.io"]
      environment  = ["dev"]

      # Intersected with the landing zone's `LandingZoneFamily` by the "Enforce Landing Zone Family
      # clearance" policy. Both landing zones here are `cloud-native`, so this has to be as well.
      LandingZoneClearance = ["cloud-native"]
    }
  }

  # The demo's three flavours. `meshBuildingBlockDefinition` has no free-form tag on this instance, so
  # the demo marker is the display name — which is also what tells the three apart in the portal.
  #
  # `ttl_days` and `budget` are only the prefilled defaults; whoever orders can still change them.
  # Sandbox and networked projects are meant to outlive the demo, hence ten years and a budget nobody
  # hits, while a university project is the time-boxed flavour the starterkit was built for.
  controltower_demo_alz = {
    sandbox = {
      display_name       = "Sandbox Project (STACKIT Control Tower demo)"
      landing_zone_name  = "likvid-stackit-default"
      ttl_days           = 3650
      budget             = 100000
      bb_environment     = "dev"
      bb_confidentiality = "internal"
      project_tags = {
        Schutzbedarf        = ["internal"]
        ResponsibilityLevel = ["Cloud Pro"]
      }
    }

    networked = {
      display_name       = "Networked Project (STACKIT Control Tower demo)"
      landing_zone_name  = "likvid-stackit-networked"
      ttl_days           = 3650
      budget             = 100000
      bb_environment     = "prod"
      bb_confidentiality = "internal"
      project_tags = {
        Schutzbedarf        = ["internal"]
        ResponsibilityLevel = ["Cloud Pro"]
      }
    }

    university = {
      display_name       = "University Project (STACKIT Control Tower demo)"
      landing_zone_name  = "likvid-stackit-default"
      ttl_days           = 30
      budget             = 100
      bb_environment     = "test"
      bb_confidentiality = "public"
      project_tags = {
        Schutzbedarf        = ["public"]
        ResponsibilityLevel = ["Beginner"]
      }
    }
  }
}

# The architecture creates the platform inside its own building block run, so there is no module
# output to read its uuid from — same reason the storage-buckets unit resolves it this way. The filter
# matches the full `<platform>.<location>` identifier; `one()` fails loudly if it stops matching
# exactly one platform.
data "meshstack_platforms" "controltower_demo" {
  identifier = "likvid-stackit.global"

  depends_on = [meshstack_building_block.this]
}

# The starterkit writes each workspace's expiry date under this tag key, and meshStack silently drops a
# tag with no definition — the workspace would read back without it and every run would see drift. The
# deploy key holds `ADM_TAGDEFINITION_SAVE`, so the definition is created here instead of by hand.
resource "meshstack_tag_definition" "workspace_expiry" {
  spec = {
    target_kind  = "meshWorkspace"
    key          = "expiry"
    display_name = "Expiry Date"
    description  = "Date this workspace and everything created with it are torn down."
    value_type   = { string = {} }
  }
}

# The module mints the `ADM_` API key the definitions authenticate with itself, in its own backplane,
# and names it after `display_name` — so each flavour gets its own key, expiring on the module's
# rotation schedule. Nothing here has to supply a credential.
module "controltower_demo_alz" {
  for_each = local.controltower_demo_alz

  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/meshstack/workspace-starterkit?ref=${local.controltower_demo_hub_git_ref}"

  platform_uuid     = one(data.meshstack_platforms.controltower_demo.platforms).ref.uuid
  landing_zone_name = each.value.landing_zone_name

  display_name                  = each.value.display_name
  workspace_ttl_days_default    = each.value.ttl_days
  payment_method_amount_default = each.value.budget

  workspace_identifier_pattern       = local.controltower_demo_workspace_identifier_pattern
  workspace_identifier_error_message = "Lowercase letters and digits, single dashes between them, at most 16 characters."

  # meshProject roles on this instance are `admin`/`user`/`reader`, not the module's default
  # "Project Admin".
  project_role_name        = "admin"
  workspace_expiry_tag_key = meshstack_tag_definition.workspace_expiry.spec.key

  meshstack = {
    owning_workspace_identifier = "stackitcontrolto"

    tags = {
      building_block = {
        LandingZoneClearance = ["cloud-native"]
        BB_Environment       = [each.value.bb_environment]
        BB_Confidentiality   = [each.value.bb_confidentiality]
      }
      workspace      = local.controltower_demo_tags.workspace
      payment_method = local.controltower_demo_tags.payment_method
      project        = merge(local.controltower_demo_tags.project, each.value.project_tags)
    }
  }

  hub = {
    git_ref = local.controltower_demo_hub_git_ref

    # Released, not the unit's `var.hub.bbd_draft`: a draft version can only be ordered by the
    # workspace that owns the definition, and the demo portal orders these for other workspaces.
    bbd_draft = false
  }
}

output "controltower_demo_alz" {
  description = "The demo's ALZ definitions, keyed by flavour, for ordering blocks against them out of band."
  value       = { for flavour, alz in module.controltower_demo_alz : flavour => alz.building_block_definition }
}

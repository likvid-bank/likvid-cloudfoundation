# Global tag definitions and policies for meshStack

import {
  id = "meshWorkspace.SecurityContact"
  to = meshstack_tag_definition.security_contact
}

# !!!! NOTE: currently the replicationKey setting is not supported by the tf provider, so you have to manually
# enable the replication key in the meshPanel UI after applying this resource.
# see https://github.com/meshcloud/terraform-provider-meshstack/issues/30

resource "meshstack_tag_definition" "security_contact" {
  provider = meshstack.cloudfoundation
  spec = {
    target_kind = "meshWorkspace"
    key         = "SecurityContact"

    display_name = "Security Contact"

    value_type = {
      # todo: should this been an email address instead? switching type is currently not allowed
      # see https://meshcloud.canny.io/feature-requests/p/support-change-of-tag-type
      string = {
        # these have to be empty strings, not null due to https://github.com/meshcloud/terraform-provider-meshstack/issues/37
        validation_regex = "",
        default_value    = ""

      }
    }

    description = "Define a person or group inbox to be contacted in case of security findings or incidents."
    sort_order  = 0
    mandatory   = true
    immutable   = false
    restricted  = false
  }
}

import {
  id = "meshWorkspace.BusinessUnit"
  to = meshstack_tag_definition.BusinessUnit
}

resource "meshstack_tag_definition" "BusinessUnit" {
  provider = meshstack.cloudfoundation
  spec = {
    target_kind = "meshWorkspace"
    key         = "BusinessUnit"

    display_name = "Business Unit"

    value_type = {
      single_select = {
        default_value = "IT"
        options = [
          "Trading",
          "IT",
          "HR",
          "Private Banking",
          "Marketing",
          "M25"
        ]
      }
    }

    description = "Select the Business Unit of Likvid Bank that owns this workspace. Please note that some cloud services are only available to select business units."
    sort_order  = 1
    mandatory   = true
    immutable   = false
    restricted  = false
  }

}
# Global tag definitions and policies for meshStack

import {
  id = "meshWorkspace.SecurityContact"
  to = meshstack_tag_definition.security_contact
}

resource "meshstack_tag_definition" "security_contact" {
  spec = {
    target_kind = "meshWorkspace"
    key         = "SecurityContact"

    display_name = "Security Contact"

    replication_key = "SecurityContact"

    value_type = {
      # todo: should this been an email address instead? switching type is currently not allowed
      # see https://meshcloud.canny.io/feature-requests/p/support-change-of-tag-type
      string = {}
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
  spec = {
    target_kind = "meshWorkspace"
    key         = "BusinessUnit"

    display_name = "Business Unit"

    replication_key = "BusinessUnit"

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
include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "platform" {
  path   = find_in_parent_folders("platform.hcl")
  expose = true
}

dependency "networking" {
  config_path = "../../networking"
}

dependency "corp_online" {
  config_path = "../../landingzones/corp-online"
}

# The pool lives in the hub subscription, which this foundation manages and meshStack does not, so
# there is no meshTenant to order the hub's building block definition against. This runs the
# building block's own module instead; it brings its azurerm provider along.
terraform {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/azure/ipam-pool/buildingblock?ref=19d0e1ec0b8648b7110a13a99bfe93b7f0821607"
}

inputs = {
  subscription_id     = dependency.networking.outputs.hub_subscription
  location            = dependency.networking.outputs.hub_location
  resource_group_name = "likvid-ipam"
  name                = "likvid-spokes"

  # Clear of the hub (10.0.0.0/16) and the hand-planned glaskugel spoke (10.1.0.0/24).
  address_prefix = "10.100.0.0/16"

  # Spokes only exist in the corp landing zones, the same scope the connectivity backplane deploys
  # into. Needs Microsoft.Network registered on that management group first, see the hub module's
  # backplane README.
  network_manager_scope = dependency.corp_online.outputs.corp_id
}

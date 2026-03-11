# Platform Backplane Module
#
# Creates the meshStack replicator and metering service accounts on the SKE cluster
# by calling the upstream terraform-kubernetes-meshplatform module.
# The kubernetes provider is inherited from the calling root (platform/main.tf).

module "meshplatform" {
  source = "git::https://github.com/meshcloud/terraform-kubernetes-meshplatform.git?ref=v0.2.0"

  replicator_enabled = true
  metering_enabled   = true
}

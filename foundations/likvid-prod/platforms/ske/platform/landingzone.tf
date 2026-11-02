locals {
  owning_workspace_identifier = "devops-platform"
  stackit_platform_uuid       = "72dcc8ad-a33f-47dd-9d21-dd0a91d36f9e"
}

# Registered by the STACKIT Landing Zone in ../../stackit/landingzone, owned by stackit-platform, so
# devops-platform may order only their released versions.
data "meshstack_building_block_definition" "service_account" {
  metadata = { uuid = "c7977de0-7a5f-4b95-981f-bbfe6405bbb1" }
}

data "meshstack_building_block_definition" "service_account_federation" {
  metadata = { uuid = "9dc16888-9fd9-43b7-9ebc-98261043b08f" }
}

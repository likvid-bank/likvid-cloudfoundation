# `meshstack_tenant.spec.platform_ref` needs a platform UUID, which only meshStack can supply, so the
# identifier is resolved into one here. A hardcoded UUID would tie this unit to one meshStack
# installation. The data source's `ref` is shaped for exactly this and passes straight through.
#
# The filter matches the full `<platform>.<location>` identifier, even though the provider documents
# it as matching `metadata.name` — filtering by the bare `aws` returns nothing. `one()` makes the unit
# fail loudly if a filter ever stops matching exactly one platform, which matters because
# `platform_ref` is RequiresReplace: a silently wrong ref replaces a live tenant.
#
# These four cover every tenant in this kit, one per distinct platform identifier, and are shared
# because three of the four are referenced from more than one resources.*.tf file.

data "meshstack_platforms" "aws" {
  identifier = "aws.aws-meshstack-dev"
}

data "meshstack_platforms" "azure" {
  identifier = "azure.meshcloud-azure-dev"
}

data "meshstack_platforms" "gcp" {
  identifier = "gcp.gcp-meshstack-dev"
}

data "meshstack_platforms" "ionos" {
  identifier = "meshcloud-ionos-dev.sovereign"
}

# The whole metering setup of this meshStack from the metering starterkit in the private repo
# meshcloud/mesh-custom-metering: the definition "Platform Metering" in `devops-platform`, which sets
# up a metering namespace on `ske-namespace.sovereign` with a metering job per selected cloud, and the
# definitions it orders: Kubernetes Manifest and STACKIT Kubernetes Workload Identity.

locals {
  # Project `stackit-kubernetes-platform` and cluster of the ske/platform unit, see ../../README.md.
  ske_project_id   = "47787660-94b9-4fb6-8bf7-53a90c41b26a"
  ske_cluster_name = "starterkit"
}

# Stored in the state, because a module variable takes no ephemeral value. `refresh` renews it on a
# run before it expires.
resource "stackit_ske_kubeconfig" "admin" {
  provider = stackit.ske

  project_id   = local.ske_project_id
  cluster_name = local.ske_cluster_name
  refresh      = true
}

# meshStack clones the Platform Metering code of the private repo with this key.
resource "tls_private_key" "mesh_custom_metering" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "mesh_custom_metering" {
  repository = "mesh-custom-metering"
  title      = "Platform Metering of the likvid demo meshStack (federation.demo.meshcloud.io)"
  key        = tls_private_key.mesh_custom_metering.public_key_openssh
  read_only  = true
}

# The filter matches the full `<platform>.<location>` identifier; `one()` fails loudly if it stops
# matching exactly one platform.
data "meshstack_platforms" "ske_namespace" {
  identifier = "ske-namespace.sovereign"
}

module "metering_starterkit" {
  source = "git::ssh://git@github.com/meshcloud/mesh-custom-metering.git//hub/modules/meshstack/metering-starterkit?ref=${var.hub.git_ref}"

  kubernetes_platform_ref      = one(data.meshstack_platforms.ske_namespace.platforms).ref
  kubernetes_landing_zone_name = "ske-namespace-prod"
  kubernetes_kubeconfig        = yamldecode(stackit_ske_kubeconfig.admin.kube_config)

  stackit_enabled             = true
  stackit_platform_identifier = "likvid-stackit.global"
  stackit_organization_id     = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  stackit_project_id          = var.stackit_project_id
  # Issuer of the SKE cluster `starterkit`, from its /.well-known/openid-configuration.
  stackit_kubernetes_oidc_issuer = "https://discovery.ske.eu01.stackit.cloud/projects/9e0d93f4f2/shoots/8128ad48-ddb8-4a8e-91b4-afe619e5307a/issuer"

  tcloud_enabled             = true
  tcloud_platform_identifier = "likvid-otc.global"
  # The T Cloud token lives only in the cluster; rotate it with ./rotate-tcloud-token.sh.

  # An API user, because the metering API accepts no API keys. Created in meshPanel, its password is in Vault.
  metering_api_user   = "custom-meshmetering-repo"
  metering_api_secret = var.metering_api_secret

  # The mandatory meshProject tags of this meshStack. `ske-namespace-prod` admits `prod` and `public`.
  metering_project_tags = {
    environment          = ["prod"]
    Schutzbedarf         = ["public"]
    LandingZoneClearance = ["cloud-native"]
    ResponsibilityLevel  = ["Cloud Pro"]
    projectOwner         = ["Platform Team"]
  }

  ssh_private_key         = tls_private_key.mesh_custom_metering.private_key_openssh
  ssh_private_key_version = sha256(tls_private_key.mesh_custom_metering.public_key_openssh)

  meshstack             = { owning_workspace_identifier = "devops-platform" }
  hub                   = var.hub
  meshstack_hub_git_ref = var.meshstack_hub_git_ref
}

output "building_block_definition" {
  value = module.metering_starterkit.building_block_definition
}

output "manifest_building_block_definition" {
  value = module.metering_starterkit.manifest_building_block_definition
}

output "metering_service_account_email" {
  value = module.metering_starterkit.stackit_metering_service_account_email
}

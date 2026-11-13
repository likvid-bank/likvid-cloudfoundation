# The whole metering setup of this meshStack from the hub's metering starterkit: the definition
# "Platform Metering" in `devops-platform`, which sets up a metering namespace on `ske-namespace.sovereign`
# with a metering job per selected cloud, and the definitions it orders: Kubernetes Service Account,
# STACKIT Metering and T Cloud Public Metering.

locals {
  # Project `stackit-kubernetes-platform` and cluster of the ske/platform unit, see ../../README.md.
  ske_project_id   = "47787660-94b9-4fb6-8bf7-53a90c41b26a"
  ske_cluster_name = "starterkit"
}

# Short-lived admin login for the `kubernetes` provider in terragrunt.hcl.
ephemeral "stackit_ske_kubeconfig" "admin" {
  provider = stackit.ske

  project_id   = local.ske_project_id
  cluster_name = local.ske_cluster_name
  expiration   = 1800
}

locals {
  admin_kubeconfig = yamldecode(ephemeral.stackit_ske_kubeconfig.admin.kube_config)
  admin_cluster    = one(local.admin_kubeconfig["clusters"])["cluster"]
  admin_user       = one(local.admin_kubeconfig["users"])["user"]
}

# The filter matches the full `<platform>.<location>` identifier; `one()` fails loudly if it stops
# matching exactly one platform.
data "meshstack_platforms" "ske_namespace" {
  identifier = "ske-namespace.sovereign"
}

module "metering_starterkit" {
  source = "git::https://github.com/meshcloud/meshstack-hub.git//modules/meshstack/metering-starterkit?ref=${var.hub.git_ref}"

  kubernetes_platform_ref      = one(data.meshstack_platforms.ske_namespace.platforms).ref
  kubernetes_landing_zone_name = "ske-namespace-prod"
  kubernetes_cluster_name      = local.ske_cluster_name
  # Written out, because the ephemeral admin kubeconfig cannot feed a module variable.
  kubernetes_cluster_server = "https://api.starterkit.9e0d93f4f2.s.ske.eu01.onstackit.cloud"
  # Teams order the Kubernetes Service Account on their own namespaces too, not only the metering.
  kubernetes_cluster_roles                    = ["view", "edit", "admin"]
  kubernetes_service_account_bbd_display_name = "Kubernetes Service Account (ske-namespace)"

  stackit_enabled             = true
  stackit_platform_identifier = "likvid-stackit.global"
  stackit_organization_id     = "05d7eb3f-f875-4bcd-ad0d-a07d62787f21"
  stackit_project_id          = var.stackit_project_id
  # Issuer of the SKE cluster `starterkit`, from its /.well-known/openid-configuration.
  stackit_kubernetes_oidc_issuer = "https://discovery.ske.eu01.stackit.cloud/projects/9e0d93f4f2/shoots/8128ad48-ddb8-4a8e-91b4-afe619e5307a/issuer"

  tcloud_enabled             = true
  tcloud_platform_identifier = "likvid-otc.global"
  # Valid for at most 90 days. Rotate it in Vault and apply again.
  tcloud_api_token = var.tcloud_api_token

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

  meshstack = { owning_workspace_identifier = "devops-platform" }
  hub       = var.hub
}

output "building_block_definition" {
  value = module.metering_starterkit.building_block_definition
}

output "service_account_building_block_definition" {
  value = module.metering_starterkit.service_account_building_block_definition
}

output "metering_service_account_email" {
  value = module.metering_starterkit.stackit_metering_service_account_email
}

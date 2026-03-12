terraform {
  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = "~> 0.19.3"
    }
  }
}

data "meshstack_workspace" "devops_platform" {
  metadata = {
    name = "devops-platform"
  }
}

resource "meshstack_project" "stackit" {
  metadata = {
    name               = "stackit-kubernetes-platform"
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
  }

  spec = {
    display_name              = "STACKIT Kubernetes Platform"
    payment_method_identifier = "devops-platform-budget"
    tags = {
      "environment"          = ["prod"]
      "LandingZoneClearance" = ["cloud-native"]
      "ResponsibilityLevel"  = ["Cloud Pro"]
      "Schutzbedarf"         = ["internal"]
      "projectOwner"         = ["Anna Admin"]
    }
  }
}

resource "meshstack_tenant_v4" "stackit" {
  metadata = {
    owned_by_workspace = data.meshstack_workspace.devops_platform.metadata.name
    owned_by_project   = meshstack_project.stackit.metadata.name
  }

  spec = {
    platform_identifier     = "stackit.sovereign"
    landing_zone_identifier = "stackit-prod"
  }
}

output "stackit_project_id" {
  description = "STACKIT project UUID provisioned by meshStack replication – consumed by kubernetes/"
  value       = meshstack_tenant_v4.stackit.spec.platform_tenant_id
}

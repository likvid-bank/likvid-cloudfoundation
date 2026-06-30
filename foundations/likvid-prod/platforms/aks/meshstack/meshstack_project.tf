locals {
  required_project_tags = {
    "LandingZoneClearance" = ["cloud-native"]
    "ResponsibilityLevel"  = ["Cloud Pro"]
    "Schutzbedarf"         = ["public"]
  }
}

resource "meshstack_project" "this" {
  metadata = {
    name               = "aks-kubernetes-platform"
    owned_by_workspace = local.owning_workspace_identifier
  }

  spec = {
    display_name              = "AKS Kubernetes Platform"
    payment_method_identifier = "devops-platform-budget"
    tags = merge(local.required_project_tags, {
      "environment"  = ["dev"]
      "projectOwner" = ["Platform Team"]
    })
  }
}

output "required_project_tags" {
  value = local.required_project_tags
}

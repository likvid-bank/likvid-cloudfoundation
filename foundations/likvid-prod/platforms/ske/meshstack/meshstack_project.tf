locals {
  required_project_tags = {
    "LandingZoneClearance" = ["cloud-native"]
    "ResponsibilityLevel"  = ["Cloud Pro"]
    "Schutzbedarf"         = ["public"] # by default, high security demand
  }
}

moved {
  from = meshstack_project.stackit
  to   = meshstack_project.this
}

resource "meshstack_project" "this" {
  metadata = {
    name               = "stackit-kubernetes-platform"
    owned_by_workspace = local.owning_workspace_identifier
  }

  spec = {
    display_name              = "STACKIT Kubernetes Platform"
    payment_method_identifier = "devops-platform-budget"
    tags = merge(local.required_project_tags, {
      "environment"  = ["prod"]
      "projectOwner" = ["Anna Admin"]
    })
  }
}

output "required_project_tags" {
  value = local.required_project_tags
}

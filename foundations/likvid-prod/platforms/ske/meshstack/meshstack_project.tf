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

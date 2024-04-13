module "policy_aviatrix" {
  source = "github.com/meshcloud/collie-hub//kit/azure/util/azure-policies?ref=ef06c8d"

  policy_path         = "${path.module}/lib"
  management_group_id = var.parent_management_group
  location            = var.location

  template_file_variables = {
    default_location          = "${var.location}"
    current_scope_resource_id = var.parent_management_group
    allowed_user_group_id     = jsonencode(concat(var.allowed_user_group_id, [azuread_service_principal.aviatrix_deploy.id]))
  }
}


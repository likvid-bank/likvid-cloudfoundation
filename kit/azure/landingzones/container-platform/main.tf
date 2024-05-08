resource "azurerm_management_group" "container_platform" {
  display_name               = var.lz-container-platform
  parent_management_group_id = var.parent_management_group_id
}

module "policy_container_platform" {
  source = "github.com/meshcloud/collie-hub//kit/azure/util/azure-policies?ref=2f2ab85c3c9530df416bb427c711979fbb7c12d6"

  policy_path         = "${path.module}/lib"
  management_group_id = azurerm_management_group.container_platform.id
  location            = var.location

  template_file_variables = {
    default_location          = "${var.location}"
    current_scope_resource_id = azurerm_management_group.container_platform.id
  }
}

resource "azurerm_resource_group" "k8s_monitoring" {
  name     = var.k8s_monitoring_rg_name
  location = var.location
}

resource "azurerm_monitor_action_group" "k8s_monitoring_action_group" {
  name                = "k8s-monitoring-action-group"
  resource_group_name = azurerm_resource_group.k8s_monitoring.name
  short_name          = "k8s-a-group"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.email_receiver
  }
}


resource "azurerm_monitor_scheduled_query_rules_alert" "k8s_baseline_alert" {
  name                = "PolicyAssignmentComplianceAlert"
  location            = azurerm_resource_group.k8s_monitoring.location
  resource_group_name = azurerm_resource_group.k8s_monitoring.name

  action {
    action_group           = [azurerm_monitor_action_group.k8s_monitoring_action_group.id]
    email_subject          = "Non-compliance alert for policy assignment K8S-Security-Baseline"
    custom_webhook_payload = "{\"policyAssignmentId\":\"K8S-Security-Baseline\",\"managementGroupId\":\"${azurerm_management_group.container_platform.name}\"}"
  }

  data_source_id = var.law_workspace_id

  description = "Alert for policy assignment compliance"

  query = <<-QUERY
    policyresources
    | where policyAssignmentId == '${module.policy_container_platform.policy_assignments["K8S-Security-Baseline"].id}'
    | where complianceState == 'NonCompliant'
  QUERY

  frequency   = 15
  time_window = 15

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}


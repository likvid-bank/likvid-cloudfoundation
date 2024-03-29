data "azurerm_subscription" "current" {
}

# workaround for https://github.com/hashicorp/terraform-provider-azurerm/issues/23014
resource "terraform_data" "subscription_name" {
  provisioner "local-exec" {
    when    = create
    command = "az account subscription rename --id ${data.azurerm_subscription.current.subscription_id} --name ${var.hub_subscription_name}"
  }
}

resource "azurerm_management_group_subscription_association" "vnet" {
  subscription_id     = data.azurerm_subscription.current.id
  management_group_id = var.connectivity_scope
}

resource "azurerm_resource_group" "hub_resource_group" {
  depends_on = [azurerm_role_assignment.cloudfoundation_tfdeploy]

  name     = var.hub_resource_group
  location = var.location
}

resource "azurerm_network_ddos_protection_plan" "hub" {
  count = var.create_ddos_plan ? 1 : 0

  name                = "${var.hub_vnet_name}-protection-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
}

resource "azurerm_virtual_network" "hub_network" {
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
  address_space       = tolist([var.address_space])

  dynamic "ddos_protection_plan" {
    for_each = var.create_ddos_plan ? [true] : []
    iterator = ddos
    content {
      id     = azurerm_ddos_protection_plan.hub.id
      enable = true
    }
  }
}

resource "azurerm_resource_group" "netwatcher" {
  count = var.netwatcher != null ? 1 : 0

  name     = "NetworkWatcherRG"
  location = azurerm_resource_group.hub_resource_group.location
}

resource "azurerm_network_watcher" "netwatcher" {
  count = var.netwatcher != null ? 1 : 0

  name                = "NetworkWatcher_${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.netwatcher[0].name
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "flowlogs" {
  name                      = "flowlogs${random_string.resource_code.result}"
  resource_group_name       = azurerm_resource_group.hub_resource_group.name
  location                  = azurerm_resource_group.hub_resource_group.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  shared_access_key_enabled = false
  min_tls_version           = "TLS1_2"
}

resource "azurerm_storage_container" "flowlogs" {
  name                  = "flowlogs"
  storage_account_name  = azurerm_storage_account.flowlogs.name
  container_access_type = "private"
}

data "azurerm_monitor_diagnostic_categories" "hub" {
  resource_id = azurerm_virtual_network.hub_network.id
}

resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count = var.diagnostics != null ? 1 : 0

  name                       = "vnet-diag"
  target_resource_id         = azurerm_virtual_network.hub_network.id
  log_analytics_workspace_id = local.parsed_diag.log_analytics_id
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.hub.log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.hub.metrics
    content {
      category = metric.value
      enabled  = contains(local.parsed_diag.metric, "all") || contains(local.parsed_diag.metric, metric.value)
    }
  }
}

# before you create a VPN gateway, you must create a gateway subnet.
# more infos about GatewaySubnets you can find here:
# https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_resource_group.name
  virtual_network_name = azurerm_virtual_network.hub_network.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 1)]

  service_endpoints = [
    "Microsoft.Storage",
  ]
}

# this is an example of an mgmt subnet for bastion hosts
# more infos about bastion u can find here
# https://learn.microsoft.com/en-us/azure/bastion/bastion-overview

resource "azurerm_subnet" "mgmt" {
  name                 = "Management"
  resource_group_name  = azurerm_resource_group.hub_resource_group.name
  virtual_network_name = azurerm_virtual_network.hub_network.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 3)]

  service_endpoints = [
    "Microsoft.Storage",
  ]
}
resource "azurerm_network_security_group" "mgmt" {
  name                = "subnet-mgmt-nsg"
  location            = azurerm_resource_group.hub_resource_group.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

resource "azurerm_network_watcher_flow_log" "mgmt_logs" {
  count = var.netwatcher != null ? 1 : 0

  network_watcher_name      = azurerm_network_watcher.netwatcher[0].name
  resource_group_name       = azurerm_resource_group.netwatcher[0].name
  name                      = "${azurerm_resource_group.hub_resource_group.name}-subnet-mgmt-nsg"
  network_security_group_id = azurerm_network_security_group.mgmt.id
  storage_account_id        = azurerm_storage_account.flowlogs.id
  enabled                   = true
  version                   = 2

  traffic_analytics {
    enabled               = true
    workspace_id          = var.netwatcher.log_analytics_workspace_id_short
    workspace_region      = var.location
    workspace_resource_id = var.netwatcher.log_analytics_workspace_id
  }

  retention_policy {
    days    = 0
    enabled = true
  }
}

data "azurerm_monitor_diagnostic_categories" "mgmt" {
  resource_id = azurerm_network_security_group.mgmt.id
}

resource "azurerm_monitor_diagnostic_setting" "mgmt" {
  count = var.diagnostics != null ? 1 : 0

  name                           = "mgmt-nsg-diag"
  target_resource_id             = azurerm_network_security_group.mgmt.id
  log_analytics_workspace_id     = local.parsed_diag.log_analytics_id
  eventhub_authorization_rule_id = local.parsed_diag.event_hub_auth_id
  storage_account_id             = local.parsed_diag.storage_account_id
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.mgmt.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_network_security_rule" "mgmt" {
  count = length(local.merged_mgmt_nsg_rules)

  resource_group_name                        = azurerm_resource_group.hub_resource_group.name
  network_security_group_name                = azurerm_network_security_group.mgmt.name
  priority                                   = 100 + 100 * count.index
  name                                       = local.merged_mgmt_nsg_rules[count.index].name
  direction                                  = local.merged_mgmt_nsg_rules[count.index].direction
  access                                     = local.merged_mgmt_nsg_rules[count.index].access
  protocol                                   = local.merged_mgmt_nsg_rules[count.index].protocol
  description                                = local.merged_mgmt_nsg_rules[count.index].description
  source_port_range                          = local.merged_mgmt_nsg_rules[count.index].source_port_range
  source_port_ranges                         = local.merged_mgmt_nsg_rules[count.index].source_port_ranges
  destination_port_range                     = local.merged_mgmt_nsg_rules[count.index].destination_port_range
  destination_port_ranges                    = local.merged_mgmt_nsg_rules[count.index].destination_port_ranges
  source_address_prefix                      = local.merged_mgmt_nsg_rules[count.index].source_address_prefix
  source_address_prefixes                    = local.merged_mgmt_nsg_rules[count.index].source_address_prefixes
  source_application_security_group_ids      = local.merged_mgmt_nsg_rules[count.index].source_application_security_group_ids
  destination_address_prefix                 = local.merged_mgmt_nsg_rules[count.index].destination_address_prefix
  destination_address_prefixes               = local.merged_mgmt_nsg_rules[count.index].destination_address_prefixes
  destination_application_security_group_ids = local.merged_mgmt_nsg_rules[count.index].destination_application_security_group_ids
}

resource "azurerm_route_table" "out" {
  name                = "${var.cloudfoundation}-outbound-rt"
  location            = azurerm_resource_group.hub_resource_group.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
}

resource "azurerm_subnet_route_table_association" "mgmt" {
  subnet_id      = azurerm_subnet.mgmt.id
  route_table_id = azurerm_route_table.out.id
}

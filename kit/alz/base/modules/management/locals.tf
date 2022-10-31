# The following block of locals are used to avoid using
# empty object types in the code.
locals {
  empty_string = ""
  empty_list   = []
  empty_map    = {}
}

# Convert the input vars to locals, applying any required
# logic needed before they are used in the module.
# No vars should be referenced elsewhere in the module.
# NOTE: Need to catch error for resource_suffix when
# no value for subscription_id is provided.
locals {
  enabled                                      = var.enabled
  root_id                                      = var.root_id
  subscription_id                              = coalesce(var.subscription_id, "00000000-0000-0000-0000-000000000000")
  settings                                     = var.settings
  location                                     = var.location
  tags                                         = var.tags
  resource_prefix                              = coalesce(var.resource_prefix, local.root_id)
  resource_suffix                              = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : local.empty_string
  existing_resource_group_name                 = var.existing_resource_group_name
  existing_log_analytics_workspace_resource_id = var.existing_log_analytics_workspace_resource_id
  existing_automation_account_resource_id      = var.existing_automation_account_resource_id
  link_log_analytics_to_automation_account     = var.link_log_analytics_to_automation_account
  custom_settings                              = var.custom_settings_by_resource_type
  asc_export_resource_group_name               = coalesce(var.asc_export_resource_group_name, "${local.root_id}-asc-export")
}

# Extract individual custom settings blocks from
# the custom_settings_by_resource_type variable.
locals {
  custom_settings_rsg               = try(local.custom_settings.azurerm_resource_group["management"], local.empty_map)
  custom_settings_la_workspace      = try(local.custom_settings.azurerm_log_analytics_workspace["management"], local.empty_map)
  custom_settings_la_solution       = try(local.custom_settings.azurerm_log_analytics_solution["management"], local.empty_map)
  custom_settings_aa                = try(local.custom_settings.azurerm_automation_account["management"], local.empty_map)
  custom_settings_la_linked_service = try(local.custom_settings.azurerm_log_analytics_linked_service["management"], local.empty_map)
}

# Logic to determine whether specific resources
# should be created by this module
locals {
  deploy_monitoring_settings          = local.settings.log_analytics.enabled
  deploy_monitoring_for_arc           = local.deploy_monitoring_settings && local.settings.log_analytics.config.enable_monitoring_for_arc
  deploy_monitoring_for_vm            = local.deploy_monitoring_settings && local.settings.log_analytics.config.enable_monitoring_for_vm
  deploy_monitoring_for_vmss          = local.deploy_monitoring_settings && local.settings.log_analytics.config.enable_monitoring_for_vmss
  deploy_monitoring_resources         = local.enabled && local.deploy_monitoring_settings
  deploy_resource_group               = local.deploy_monitoring_resources && local.existing_resource_group_name == local.empty_string
  deploy_log_analytics_workspace      = local.deploy_monitoring_resources && local.existing_log_analytics_workspace_resource_id == local.empty_string
  deploy_log_analytics_linked_service = local.deploy_monitoring_resources && local.link_log_analytics_to_automation_account
  deploy_automation_account           = local.deploy_monitoring_resources && local.existing_automation_account_resource_id == local.empty_string
  deploy_azure_monitor_solutions = {
    AgentHealthAssessment       = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_agent_health_assessment
    AntiMalware                 = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_anti_malware
    AzureActivity               = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_azure_activity
    ChangeTracking              = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_change_tracking
    Security                    = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_sentinel
    SecurityInsights            = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_sentinel
    ServiceMap                  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_service_map
    SQLAssessment               = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_assessment
    SQLVulnerabilityAssessment  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_vulnerability_assessment
    SQLAdvancedThreatProtection = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_advanced_threat_detection
    Updates                     = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_updates
    VMInsights                  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_vm_insights
  }
  deploy_security_settings           = local.settings.security_center.enabled
  deploy_defender_for_app_services   = local.settings.security_center.config.enable_defender_for_app_services
  deploy_defender_for_arm            = local.settings.security_center.config.enable_defender_for_arm
  deploy_defender_for_containers     = local.settings.security_center.config.enable_defender_for_containers
  deploy_defender_for_dns            = local.settings.security_center.config.enable_defender_for_dns
  deploy_defender_for_key_vault      = local.settings.security_center.config.enable_defender_for_key_vault
  deploy_defender_for_oss_databases  = local.settings.security_center.config.enable_defender_for_oss_databases
  deploy_defender_for_servers        = local.settings.security_center.config.enable_defender_for_servers
  deploy_defender_for_sql_servers    = local.settings.security_center.config.enable_defender_for_sql_servers
  deploy_defender_for_sql_server_vms = local.settings.security_center.config.enable_defender_for_sql_server_vms
  deploy_defender_for_storage        = local.settings.security_center.config.enable_defender_for_storage
}

# Configuration settings for resource type:
#  - azurerm_resource_group
locals {
  resource_group_name = coalesce(
    local.existing_resource_group_name,
    lookup(local.custom_settings_rsg, "name", "${local.resource_prefix}-mgmt"),
  )
  resource_group_resource_id = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}"
  azurerm_resource_group = {
    name     = local.resource_group_name,
    location = lookup(local.custom_settings_rsg, "location", local.location)
    tags     = lookup(local.custom_settings_rsg, "tags", local.tags)
  }
}


# Configuration settings for resource type:
#  - azurerm_log_analytics_workspace
locals {
  log_analytics_workspace_resource_id = coalesce(
    local.existing_log_analytics_workspace_resource_id,
    "${local.resource_group_resource_id}/providers/Microsoft.OperationalInsights/workspaces/${local.azurerm_log_analytics_workspace.name}"
  )
  azurerm_log_analytics_workspace = {
    name                              = lookup(local.custom_settings_la_workspace, "name", "${local.resource_prefix}-la${local.resource_suffix}")
    resource_group_name               = lookup(local.custom_settings_la_workspace, "resource_group_name", local.resource_group_name)
    location                          = lookup(local.custom_settings_la_workspace, "location", local.location)
    sku                               = lookup(local.custom_settings_la_workspace, "sku", "PerGB2018")
    retention_in_days                 = lookup(local.custom_settings_la_workspace, "retention_in_days", local.settings.log_analytics.config.retention_in_days)
    daily_quota_gb                    = lookup(local.custom_settings_la_workspace, "daily_quota_gb", null)
    internet_ingestion_enabled        = lookup(local.custom_settings_la_workspace, "internet_ingestion_enabled", true)
    internet_query_enabled            = lookup(local.custom_settings_la_workspace, "internet_query_enabled", true)
    reservation_capcity_in_gb_per_day = lookup(local.custom_settings_la_workspace, "reservation_capcity_in_gb_per_day", null) # Requires version = "~> 2.48.0"
    tags                              = lookup(local.custom_settings_la_workspace, "tags", local.tags)
  }
}

# Configuration settings for resource type:
#  - azurerm_log_analytics_solution
locals {
  log_analytics_solution_resource_id = {
    for resource in local.azurerm_log_analytics_solution :
    resource.solution_name => "${local.resource_group_resource_id}/providers/Microsoft.OperationsManagement/solutions/${resource.solution_name}(${local.azurerm_log_analytics_workspace.name})"
  }
  azurerm_log_analytics_solution = [
    for solution_name, solution_enabled in local.deploy_azure_monitor_solutions :
    {
      solution_name         = solution_name
      resource_group_name   = lookup(local.custom_settings_la_solution, "resource_group_name", local.resource_group_name)
      location              = lookup(local.custom_settings_la_solution, "location", local.location)
      workspace_resource_id = local.log_analytics_workspace_resource_id
      workspace_name        = basename(local.log_analytics_workspace_resource_id)
      tags                  = lookup(local.custom_settings_la_solution, "tags", local.tags)
      plan = {
        publisher = "Microsoft"
        product   = "OMSGallery/${solution_name}"
      }
    }
    if solution_enabled
  ]
}

# Configuration settings for resource type:
#  - azurerm_automation_account
locals {
  automation_account_resource_id = coalesce(
    local.existing_automation_account_resource_id,
    "${local.resource_group_resource_id}/providers/Microsoft.Automation/automationAccounts/${local.azurerm_automation_account.name}"
  )
  # As per issue #449, some automation accounts should be created in a different region to the log analytics workspace
  # The automation_account_location_map local is used to track these
  automation_account_location_map = {
    eastus  = "eastus2"
    eastus2 = "eastus"
  }
  automation_account_location = coalesce(
    lookup(local.custom_settings_aa, "location", null),
    lookup(local.automation_account_location_map, local.location, local.location)
  )
  azurerm_automation_account = {
    name                = lookup(local.custom_settings_aa, "name", "${local.resource_prefix}-automation${local.resource_suffix}")
    resource_group_name = lookup(local.custom_settings_aa, "resource_group_name", local.resource_group_name)
    location            = lookup(local.custom_settings_aa, "location", local.automation_account_location)
    sku_name            = lookup(local.custom_settings_aa, "sku_name", "Basic")
    identity            = lookup(local.custom_settings_aa, "identity", local.empty_list)
    tags                = lookup(local.custom_settings_aa, "tags", local.tags)
  }
}

# Configuration settings for resource type:
#  - azurerm_log_analytics_linked_service
locals {
  log_analytics_linked_service_resource_id = "${local.log_analytics_workspace_resource_id}/linkedServices/Automation"
  azurerm_log_analytics_linked_service = {
    resource_group_name = lookup(local.custom_settings_la_linked_service, "resource_group_name", local.resource_group_name)
    workspace_id        = lookup(local.custom_settings_la_linked_service, "workspace_id", local.log_analytics_workspace_resource_id)
    read_access_id      = lookup(local.custom_settings_la_linked_service, "read_access_id", local.automation_account_resource_id) # This should be used for linking to an Automation Account resource.
    write_access_id     = null                                                                                                    # DO NOT USE. This should be used for linking to a Log Analytics Cluster resource
  }
}

# Archetype configuration overrides
locals {
  archetype_config_overrides = {
    (local.root_id) = {
      parameters = {
        Deploy-MDFC-Config = {
          emailSecurityContact           = local.settings.security_center.config.email_security_contact
          logAnalytics                   = local.log_analytics_workspace_resource_id
          ascExportResourceGroupName     = local.asc_export_resource_group_name
          ascExportResourceGroupLocation = local.location
          enableAscForAppServices        = local.deploy_defender_for_app_services ? "DeployIfNotExists" : "Disabled"
          enableAscForArm                = local.deploy_defender_for_arm ? "DeployIfNotExists" : "Disabled"
          enableAscForContainers         = local.deploy_defender_for_containers ? "DeployIfNotExists" : "Disabled"
          enableAscForDns                = local.deploy_defender_for_dns ? "DeployIfNotExists" : "Disabled"
          enableAscForKeyVault           = local.deploy_defender_for_key_vault ? "DeployIfNotExists" : "Disabled"
          enableAscForOssDb              = local.deploy_defender_for_oss_databases ? "DeployIfNotExists" : "Disabled"
          enableAscForServers            = local.deploy_defender_for_servers ? "DeployIfNotExists" : "Disabled"
          enableAscForSql                = local.deploy_defender_for_sql_servers ? "DeployIfNotExists" : "Disabled"
          enableAscForSqlOnVm            = local.deploy_defender_for_sql_server_vms ? "DeployIfNotExists" : "Disabled"
          enableAscForStorage            = local.deploy_defender_for_storage ? "DeployIfNotExists" : "Disabled"
        }
        Deploy-LX-Arc-Monitoring = {
          logAnalytics = local.log_analytics_workspace_resource_id

        }
        Deploy-VM-Monitoring = {
          logAnalytics_1 = local.log_analytics_workspace_resource_id

        }
        Deploy-VMSS-Monitoring = {
          logAnalytics_1 = local.log_analytics_workspace_resource_id
        }
        Deploy-WS-Arc-Monitoring = {
          logAnalytics = local.log_analytics_workspace_resource_id
        }
        Deploy-AzActivity-Log = {
          logAnalytics = local.log_analytics_workspace_resource_id
        }
        Deploy-Resource-Diag = {
          logAnalytics = local.log_analytics_workspace_resource_id
        }
      }
      enforcement_mode = {
        Deploy-MDFC-Config       = local.deploy_security_settings
        Deploy-LX-Arc-Monitoring = local.deploy_monitoring_for_arc
        Deploy-VM-Monitoring     = local.deploy_monitoring_for_vm
        Deploy-VMSS-Monitoring   = local.deploy_monitoring_for_vmss
        Deploy-WS-Arc-Monitoring = local.deploy_monitoring_for_arc
      }
    }
    "${local.root_id}-management" = {
      parameters = {
        Deploy-Log-Analytics = {
          automationAccountName = local.azurerm_automation_account.name
          automationRegion      = local.azurerm_automation_account.location
          rgName                = local.azurerm_resource_group.name
          workspaceName         = local.azurerm_log_analytics_workspace.name
          workspaceRegion       = local.azurerm_log_analytics_workspace.location
          # Need to ensure dataRetention gets handled as a string
          dataRetention = tostring(local.azurerm_log_analytics_workspace.retention_in_days)
          # Need to ensure sku value is set to lowercase only when "PerGB2018" specified
          # Evaluating in lower() to ensure the correct error is surfaced on the resource if invalid casing is used
          sku = lower(local.azurerm_log_analytics_workspace.sku) == "pergb2018" ? lower(local.azurerm_log_analytics_workspace.sku) : local.azurerm_log_analytics_workspace.sku
        }
      }
      enforcement_mode = {
        Deploy-Log-Analytics = local.deploy_monitoring_settings
      }
    }
  }
}

# Template file variable outputs
locals {
  template_file_variables = {
    log_analytics_workspace_resource_id = local.log_analytics_workspace_resource_id
    log_analytics_workspace_name        = local.azurerm_log_analytics_workspace.name
    log_analytics_workspace_location    = local.azurerm_log_analytics_workspace.location
    automation_account_resource_id      = local.automation_account_resource_id
    automation_account_name             = local.azurerm_automation_account.name
    automation_account_location         = local.azurerm_automation_account.location
    management_location                 = local.location
    management_resource_group_name      = local.azurerm_resource_group.name
    data_retention                      = tostring(local.azurerm_log_analytics_workspace.retention_in_days)
  }
}

# Generate the configuration output object for the management module
locals {
  module_output = {
    azurerm_resource_group = [
      {
        resource_id   = local.resource_group_resource_id
        resource_name = basename(local.resource_group_resource_id)
        template = {
          for key, value in local.azurerm_resource_group :
          key => value
          if local.deploy_resource_group
        }
        managed_by_module = local.deploy_resource_group
      },
    ]
    azurerm_log_analytics_workspace = [
      {
        resource_id   = local.log_analytics_workspace_resource_id
        resource_name = basename(local.log_analytics_workspace_resource_id)
        template = {
          for key, value in local.azurerm_log_analytics_workspace :
          key => value
          if local.deploy_log_analytics_workspace
        }
        managed_by_module = local.deploy_log_analytics_workspace
      },
    ]
    azurerm_log_analytics_solution = [
      for resource in local.azurerm_log_analytics_solution :
      {
        resource_id       = local.log_analytics_solution_resource_id[resource.solution_name]
        resource_name     = basename(local.log_analytics_solution_resource_id[resource.solution_name])
        template          = resource
        managed_by_module = true
      }
    ]
    azurerm_automation_account = [
      {
        resource_id   = local.automation_account_resource_id
        resource_name = basename(local.automation_account_resource_id)
        template = {
          for key, value in local.azurerm_automation_account :
          key => value
          if local.deploy_automation_account
        }
        managed_by_module = local.deploy_automation_account
      },
    ]
    azurerm_log_analytics_linked_service = [
      {
        resource_id   = local.log_analytics_linked_service_resource_id
        resource_name = basename(local.log_analytics_linked_service_resource_id)
        template = {
          for key, value in local.azurerm_log_analytics_linked_service :
          key => value
          if local.deploy_log_analytics_linked_service
        }
        managed_by_module = local.deploy_log_analytics_linked_service
      },
    ]
    archetype_config_overrides = local.archetype_config_overrides
    template_file_variables    = local.template_file_variables
  }
}

locals {
  cluster_name        = "aks-likvid"
  resource_group_name = "aks-likvid"
}

resource "azurerm_automation_account" "aks_scheduler" {
  name                = "aks-likvid-scheduler"
  location            = "Germany West Central"
  resource_group_name = local.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [module.aks]
}

# Scope to the resource group so the runbooks can stop/start only the AKS cluster inside it.
resource "azurerm_role_assignment" "automation_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.aks_scheduler.identity[0].principal_id
}

resource "azurerm_automation_runbook" "stop_cluster" {
  name                    = "stop-aks-cluster"
  location                = "Germany West Central"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  log_verbose             = false
  log_progress            = false
  runbook_type            = "PowerShell"

  content = <<-PWSH
    Disable-AzContextAutosave -Scope Process
    Connect-AzAccount -Identity
    $subId = (Get-AzContext).Subscription.Id
    Write-Output "Stopping AKS cluster ${local.cluster_name}..."
    Invoke-AzRestMethod -Method POST `
      -Uri "https://management.azure.com/subscriptions/$subId/resourceGroups/${local.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${local.cluster_name}/stop?api-version=2024-02-01"
    Write-Output "Stop request sent."
  PWSH
}

resource "azurerm_automation_runbook" "start_cluster" {
  name                    = "start-aks-cluster"
  location                = "Germany West Central"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  log_verbose             = false
  log_progress            = false
  runbook_type            = "PowerShell"

  content = <<-PWSH
    Disable-AzContextAutosave -Scope Process
    Connect-AzAccount -Identity
    $subId = (Get-AzContext).Subscription.Id
    Write-Output "Starting AKS cluster ${local.cluster_name}..."
    Invoke-AzRestMethod -Method POST `
      -Uri "https://management.azure.com/subscriptions/$subId/resourceGroups/${local.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${local.cluster_name}/start?api-version=2024-02-01"
    Write-Output "Start request sent."
  PWSH
}

# Friday 19:00 Europe/Berlin — cluster goes down for the weekend
resource "azurerm_automation_schedule" "friday_stop" {
  name                    = "friday-stop"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Friday"]
  start_time              = "2026-07-03T19:00:00+02:00" # upcoming Friday (CEST); Azure computes next occurrence from here
  timezone                = "Europe/Berlin"

  lifecycle {
    ignore_changes = [start_time] # start_time drifts as Azure advances the schedule
  }
}

# Monday 06:00 Europe/Berlin — cluster comes back up for the week
resource "azurerm_automation_schedule" "monday_start" {
  name                    = "monday-start"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Monday"]
  start_time              = "2026-07-06T06:00:00+02:00" # upcoming Monday (CEST); Azure computes next occurrence from here
  timezone                = "Europe/Berlin"

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_job_schedule" "stop_on_friday" {
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  runbook_name            = azurerm_automation_runbook.stop_cluster.name
  schedule_name           = azurerm_automation_schedule.friday_stop.name
}

resource "azurerm_automation_job_schedule" "start_on_monday" {
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  runbook_name            = azurerm_automation_runbook.start_cluster.name
  schedule_name           = azurerm_automation_schedule.monday_start.name
}

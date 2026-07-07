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

# The cluster runs Monday–Friday 05:00–21:00 Europe/Berlin and is off overnight and over the
# weekend. Friday stops early (19:00) and stays down until Monday morning, so the nightly stop
# skips Friday and the weekend.

# Friday 19:00 Europe/Berlin — cluster goes down for the weekend
resource "azurerm_automation_schedule" "friday_stop" {
  name                    = "friday-stop"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Friday"]
  start_time              = "2026-07-10T19:00:00+02:00" # upcoming Friday (CEST); Azure computes next occurrence from here
  timezone                = "Europe/Berlin"

  lifecycle {
    ignore_changes = [start_time] # start_time drifts as Azure advances the schedule
  }
}

# Monday–Thursday 21:00 Europe/Berlin — cluster goes down for the night
resource "azurerm_automation_schedule" "nightly_stop" {
  name                    = "nightly-stop"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday"]
  start_time              = "2026-07-08T21:00:00+02:00" # upcoming Wednesday (CEST); Azure computes next occurrence from here
  timezone                = "Europe/Berlin"

  lifecycle {
    ignore_changes = [start_time]
  }
}

# Monday–Friday 05:00 Europe/Berlin — cluster comes back up for the day
resource "azurerm_automation_schedule" "weekday_start" {
  name                    = "weekday-start"
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  start_time              = "2026-07-08T05:00:00+02:00" # upcoming Wednesday (CEST); Azure computes next occurrence from here
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

resource "azurerm_automation_job_schedule" "stop_nightly" {
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  runbook_name            = azurerm_automation_runbook.stop_cluster.name
  schedule_name           = azurerm_automation_schedule.nightly_stop.name
}

resource "azurerm_automation_job_schedule" "start_on_weekdays" {
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.aks_scheduler.name
  runbook_name            = azurerm_automation_runbook.start_cluster.name
  schedule_name           = azurerm_automation_schedule.weekday_start.name
}

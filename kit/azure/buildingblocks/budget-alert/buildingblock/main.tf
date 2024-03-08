locals {
  # azure requires a startdate in the current month
  start_date = formatdate("YYYY-MM-01'T'hh:mm:ssZ", timestamp())
  contact_emails_list = [
    for x in split(",", var.contact_emails) : trimspace(x)
  ]
}

data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

resource "azurerm_consumption_budget_subscription" "subscription_budget" {
  name            = var.budget_name
  subscription_id = data.azurerm_subscription.subscription.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = local.start_date
    # end_date: If not set this will be 10 years after the start date.
  }

  notification {
    enabled   = true
    threshold = var.actual_threshold_percent
    operator  = "EqualTo"

    contact_emails = local.contact_emails_list
  }

  notification {
    enabled        = true
    threshold      = var.forcasted_threshold_percent
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = local.contact_emails_list
  }
}
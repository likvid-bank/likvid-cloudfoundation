---
name: Azure Logging
summary: |
  This module sets up and Azure Log Analytics Workspace and ensures collection of Azure logs in all
  subscriptions under a management group via policy.
compliance:
  - control: cfmm/security-and-compliance/centralized-audit-logs
    statement: |
      Activates Azure logs in all subscriptions and sends them to a central log analytics workspace for
      storage and analysis.
---

# Logging


## Getting started with log analytics workspace

If you have not done so already, move an existing subscription into the management group hierarchy and check the policy assignment status in Azure Portal.
We expect to see that the scope is compliant with the policy.

Here is how you interact with logs in your new workspace.

Open log analytics workspace in Azure portal.
Choose the newly created workspace.
Choose Workbooks → Activity Logs Insights.
You will see stats about the Activity Logs streamed from the connected subscriptions to the log analytics workspace.
> This assumes that in some Activity Log items has been generated in any of the

Alternatively, you can query logs. To do so, choose Logs in your workspace.

Here is a query that displays the last 50 Activity log events:
```
// Display top 50 Activity log events.
AzureActivity
| project TimeGenerated, SubscriptionId, ResourceGroup,ResourceProviderValue,OperationNameValue,CategoryValue,CorrelationId,ActivityStatusValue, ActivitySubstatusValue, Properties_d, Caller
| top 50 by TimeGenerated
```

<!-- BEGIN_TF_DOCS -->
cloudfoundation            = ""
location                   = ""
log_retention_in_days      = 30
logging_subscription_name  = "logging"
parent_management_group_id = ""
scope                      = ""
security_admin_group       = "cloudfoundation-security-admins"
security_auditor_group     = "cloudfoundation-security-auditors"
<!-- END_TF_DOCS -->

---
name: Azure Building Block - Subscription Budget Alert
summary: |
  Building block module for adding a simple monthly budget alert to a subscription.
---

# Azure Subscription Budget Alert

This documentation is intended as a reference documentation for cloud foundation or platform engineers using this module.

## Permissions

This is a very simple building block, which means we let the SPN have access to deploy budget alerts 
across all subscriptions underneath a management group (typically the top-level management group for landing zones).

<!-- BEGIN_TF_DOCS -->
bb_admins_group_id     = ""
location               = ""
name                   = ""
scope                  = ""
service_principal_name = ""
<!-- END_TF_DOCS -->
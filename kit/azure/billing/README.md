---
name: Azure billing
summary: |
  Set up Azure Cost Management to monitor, allocate, and optimize cost across the entire organization.
compliance:
  - control: cfmm/cost-management/monthly-cloud-tenant-billing-report
    statement: |
      Enables application teams as well as controlling team members to review costs for each subscription.
  - control: cfmm/cost-management/billing-alerts
    statement: |
      Sets up centralized budget alerts monitoring total cloud spend.
---

# Azure Billing

Microsoft Cost Management is a suite of tools that help organizations monitor, allocate, and optimize the cost of their Microsoft Cloud workloads. Cost Management is available to anyone with access to a billing or resource management scope. The availability includes anyone from the cloud finance team with access to the billing account. And, to DevOps teams managing resources in subscriptions and resource groups. Together, Cost Management and Billing are your gateway to the Microsoft Commerce system that’s available to everyone throughout the journey.


<!-- BEGIN_TF_DOCS -->
billing_admin_group  = "cloudfoundation-billing-admins"
billing_reader_group = "cloudfoundation-billing-readers"
budget_amount        = 100
budget_name          = "cloudfoundation_budget"
budget_time_period = [
  {
    "end": "2022-07-01T00:00:00Z",
    "start": "2022-06-01T00:00:00Z"
  }
]
contact_mails = [
  "billingmeshi@meshithesheep.io"
]
scope = ""
<!-- END_TF_DOCS -->

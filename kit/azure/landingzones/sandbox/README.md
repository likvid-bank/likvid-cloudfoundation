---
name: Azure Landing Zone "Sandbox"
summary: |
  A sandbox landing zone in Azure is essentially a controlled and isolated space where users can deploy and test
  various resources, applications, and configurations without affecting the production environment.
compliance:
- control: cfmm/tenant-management/playground-sandbox-environments
  statement: |
    It's a best practice for development, testing, and learning purposes, providing a safe and secure area to explore Azure services
    and features. This allows users to gain hands-on experience without the risk of impacting critical systems.
- control: cfmm/security-and-compliance/service-and-location-restrictions
  statement: |
    Forbids use of certain Azure Services that are unsuitable for experimentation environments because they incur high cost and/or allow establishing non-zero-trust connectivity via VNet peering to other services.
---

# Azure Landing Zone "sandbox"

This kit provides a Terraform configuration for setting a sandbox landing zone management group and suitable default policies.

<!-- BEGIN_TF_DOCS -->
location                   = ""
name                       = "sandbox"
parent_management_group_id = ""
<!-- END_TF_DOCS -->

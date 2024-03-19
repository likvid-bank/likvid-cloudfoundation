---
name: Azure Landing Zone "Corp-Online"
summary: |
  deploys the parent Management Group for Corp/Online Landingzones.
compliance:
- control: cfmm/security-and-compliance/service-and-location-restrictions
  statement: |
    Restricts deployment of vWAN/ER/VPN gateway resources in the Corp landing zone
    Restricts creation of Azure PaaS services with exposed public endpoints
    Restricts network interfaces from having a public IP associated to it under the assigned scope
- control: cfmm/security-and-compliance/centralized-audit-logs
  statement: |
      Audits the deployment of Private Link Private DNS Zone resources in the Corp landing zone.
---

# Azure Landing Zone "Corp-Online"

This kit provides a Terraform configuration for setting up Azure Management Groups for dedicated Management Group for Online and Corp landing zones, meaning workloads that may require direct internet inbound/outbound connectivity or also for workloads that may not require a VNet will live in Online. Landingzones which requires connectivity/hybrid connectivity with the corporate network thru the hub in the connectivity subscription will live on Corp.

<!-- BEGIN_TF_DOCS -->
cloudfoundation            = ""
corp                       = "corp"
landingzones               = "lv-landingzones"
location                   = "germanywestcentral"
online                     = "online"
parent_management_group_id = "lv-foundation"
<!-- END_TF_DOCS -->

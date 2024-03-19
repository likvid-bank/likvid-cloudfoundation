---
name: Azure Landing Zone "Serverless"
summary: |
  deploys new cloud foundation infrastructure.
  Add a concise description of the module's purpose here.
compliance:
- control: cfmm/security-and-compliance/service-and-location-restrictions
  statement: |
    Restricts the list of permitted Azure services in relation to Serverless.
---

# Azure Landing Zone "Serverless"

This kit provides a Terraform configuration for setting up Azure Management Groups for dedicated Management Group and policy for Serverless Landingzones.

<!-- BEGIN_TF_DOCS -->
landingzones               = "lv-landingzones"
location                   = "germanywestcentral"
lz-serverless              = "serverless"
parent_management_group_id = "lv-foundation"
<!-- END_TF_DOCS -->

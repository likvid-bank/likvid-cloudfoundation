---
name: Azure Organization Hierarchy
summary: |
  deploys the Azure Organization Hierarchy.
compliance:
- control: cfmm/security-and-compliance/service-and-location-restrictions
  statement: |
    Restricts locations for cloud resources to EU regions only.
    Restricts list of allowed Azure Services do deny Azure classic resources.
- control: cfmm/security-and-compliance/resource-configuration-scanning
  statement: |
    Audit policies check Azure Key Vault configuration and the SSL/TLS configuration of select Azure services.
- control: cfmm/security-and-compliance/resource-configuration-policies
  statement: |
    Deploy policies enforcing security best-practices for key Azure services
      - Subnets
      - Azure Key Vault
      - SSL/TLS configuration of select Azure services
- control: cfmm/service-ecosystem/managed-key-vault
  statement: |
    Enforce and monitor expiration for secrets and keys and enable deletion protection.
    This helps ensure application-team managed key vaults are set up and configured according to best practices.
    Note: Key Vaults are not fully managed by the cloud foundation team, they stay within the application teams responsibility.
---

# Azure Organization Hierarchy

This repository provides a Terraform configuration for setting up Azure Management Groups in alignment with the Azure Enterprise Scale Cloud Adoption Framework (CAF). The management groups enable efficient management, access control, and policy enforcement across multiple Azure subscriptions.

This kit module forms the core of your [Azure Landing Zone architecture](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-architecture). You can build on this with other kit
modules, see [related kit modules](#related-kit-modules) below.

## Overview

The Terraform configuration in this repository establishes a hierarchical structure of management groups to organize and govern Azure resources effectively.

This kit module provides a good starting point with many commonly deployed policies.
You should however tailor this approach to your organization's individual needs and think through the rationale
of each policy. The [security & compliance pillar](https://cloudfoundation.org/maturity-model/security-and-compliance/) of the cloud foundation maturity model can provide useful guidance about which policies are essential and which ones are more optional.

It's fine to throw some policies out instead of going all in with the defaults. Remember, you can always iterate on
your kit modules. This is useful when you're just starting out and want to keep things simple, or when you already have
a lot of existing Azure resources and need to be careful about not disrupting existing workloads.

## Related Kit Modules

After deploying this module, you should probably deploy the following kit modules next to

- [Activity Log Kit Module](./activity-log/README.md)
<!-- TODO
- [Corp Kit Module](../corp/README.md)
- landing zones
- -->

<!-- BEGIN_TF_DOCS -->
connectivity = "lv-connectivity"
identity     = "lv-identity"
landingzones = "lv-landingzones"
locations = [
  "germanywestcentral"
]
management                   = "lv-management"
management_subscription_name = "management"
parentManagementGroup        = "lv-foundation"
platform                     = "lv-platform"
<!-- END_TF_DOCS -->

---
name: Azure Privileged Access Management
summary: |
  Privileged Access Management (PAM) refers to the implementation of security measures and best practices to control and monitor access to critical resources within cloud platforms. For cloud foundation teams, it is about safeguarding administrative roles that enable access to core infrastructure, ensuring the security, compliance, and visibility needed to oversee application teams' cloud usage.
compliance:
  - control: cfmm/iam/privileged-access-management
    statement: |
       Implements PAM for security auditors, billing readers, network admins.
---

# Privileged Access Management

This kit provides a basic terraform-based approach for managing privileged roles used to administrate your landing zones.

This is a good solution for cloud foundation teams that start in greenfield Azure environments and without a strong
backing of established enterprise IAM integration into Entra ID (Azure AD).

> For production use, cloud foundation teams should strongly consider implementing group membership management using
> existing Enterprise IAM processes as well as leveraging Entra ID PIM and Conditional Access features to increase
> security.

This module is meant to be used with modules like `azure/billing` or `azure/logging` that implement important
administrative capabilities and also introduce relevant security groups and security roles for managing these capabilities.

Thee purpose of this kit module is then to collect the various PAM groups and permissions together and provide a central
and cohesive overview.


<!-- BEGIN_TF_DOCS -->
pam_group_members    = ""
pam_group_object_ids = ""
<!-- END_TF_DOCS -->

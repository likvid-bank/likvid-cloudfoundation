---
name: Azure Landing Zone "Cloud-Native"
summary: |
compliance:
- control: cfmm/cloud-native-landing-zone
  statement: |
    A dedicated landing zone optimized for cloud-native workloads enables quick
    onboarding and efficient operations.
---

# Azure Landing Zone "Cloud-Native"

 Cloud Native Landing Zone is a purpose-built environment in the cloud designed to streamline the development, deployment,
 and operation of applications. It incorporates automation, security measures, and best practices for cloud-native development
 to ensure efficient and secure utilization of cloud resources.

The kit will create a dev group and a prod management groups.

<!-- BEGIN_TF_DOCS -->
name                       = "cloudnative"
parent_management_group_id = ""
<!-- END_TF_DOCS -->

output "documentation_md" {
  value = <<EOF
# Containerized Serverless Landing Zone

A Containerized Serverless Landing Zone is a pre-configured infrastructure setup designed to support the deployment of containerized serverless applications.

- **${resource.azurerm_management_group.container_platform.display_name}** - this is the severless management group

### Active Policies

#### Service and Location Restrictions

|Policy|Effect|Description|Rationale|
|-|-|-|-|
|${module.policy_container_platform.policy_assignments["K8S-Security-Baseline"].display_name}|Audit|${module.policy_container_platform.policy_assignments["K8S-Security-Baseline"].description}|This initiative enforces several security best practices for Kubernetes pods, such as running containers as a non-root user and not allowing privilege escalation. These practices help to minimize the attack surface of your Kubernetes workloads and protect against common security threats.|

- [Cloud Foundation Maturity Model](https://cloudfoundation.org/maturity-model/tenant-management/container-platform-landing-zone.html)
- [Azure Policy Initiative](https://www.azadvertizer.net/azpolicyinitiativesadvertizer/a8640138-9b0a-4a28-b8cb-1666c838647d.html)
EOF
}

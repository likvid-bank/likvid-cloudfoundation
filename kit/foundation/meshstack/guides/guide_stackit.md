# STACKIT Custom Platform

This guide explains how to integrate STACKIT as a cloud provider in the meshStack platform, enabling application teams to use STACKIT for deploying workloads while leveraging its European-first, GDPR-compliant infrastructure.

---

## Motivation

The Likvid Bank rely on meshStack to standardize cloud access across teams and ensure compliance with internal and external requirements. By adding STACKIT to the mix, platform teams can offer a secure and reliable cloud provider that aligns perfectly with European data protection standards.


---

## Challenges

- **Compliance:** Ensure workloads run in a fully GDPR-compliant environment.
- **Flexibility:** Provide an additional cloud provider choice for application teams alongside other providers in the meshStack marketplace.
- **Ease of Use:** Make STACKIT easily consumable by integrating it into meshStack’s platform workflows.

---

## Features of STACKIT in meshStack

1. **European Data Sovereignty:**
   - All workloads are hosted in certified EU data centers (e.g., in Germany or Austria).

4. **Wide Range of Services:**
   - STACKIT provides virtual machines, Kubernetes clusters, and storage options to meet diverse application needs.

---

# Integrating STACKIT with meshStack

### 1. Setting up STACKIT

1. **Create a STACKIT Account**
   - Register via the [STACKIT Portal](https://stackit.de).

2. **Set Up Project Management**
   - Create a management project in your STACKIT organization.

3. **Configure a Service Account**
   - Create a service account in the management project and generate a token for your organization.
   - Grant the service account sufficient permissions to create tenants in your organization.

---

### 2. Deploy the STACKIT Landing Zone reference architecture

The integration is no longer assembled by hand. meshcloud maintains a **STACKIT Landing Zone reference
architecture** in [meshstack-hub](https://github.com/meshcloud/meshstack-hub/tree/main/reference-architectures/stackit-landingzone),
and ordering it once creates the whole integration: the meshPlatform, its landing zones, the mandatory
`STACKIT Project` building block definition, the STACKIT folder that tenant projects live in, and the
service account that creates them.

Likvid Bank deploys it from `foundations/likvid-prod/platforms/stackit/landingzone/`, which sources the
architecture as a Terraform module and then orders it once with `meshstack_building_block` against the
`stackit-platform` workspace.

The inputs that matter:

- `platform_identifier` names the meshPlatform, the STACKIT folder and the foundation project. Likvid
  Bank uses `likvid-stackit`.
- `use_global_location = true` puts the platform in the shared `global` location, giving the identifier
  `likvid-stackit.global`. Left unset, the architecture creates its own location and the identifier
  becomes `likvid-stackit.likvid-stackit`.
- `stackit_service_account_key` is an organization-owner key. The architecture needs to act inside a
  project it does not own, which a narrower role cannot do.

### 3. Publish the platform

The architecture deliberately creates the platform `PRIVATE` and `UNPUBLISHED`, so a platform engineer
decides when it becomes visible. That step is manual and cannot be done in code, because the resource
ignores changes to its availability on purpose.

Publishing takes two steps in this order, and the first leaves a visible intermediate state:

1. Publish to the marketplace. The platform becomes `RESTRICTED` rather than public, because its
   allowed-workspaces list still holds the owner.
2. Clear the allowed-workspaces list. The platform becomes `PUBLIC`.

Going straight to public is refused, because an empty allowed-workspaces list would lock the owner out
of a platform that has never been published.

Application teams then order STACKIT projects through the landing zone, and meshStack instantiates the
mandatory `STACKIT Project` building block for every new meshTenant.

---

## Conclusion

By following this guide, Likvid Bank provides a European cloud solution via meshStack, enabling DSGVO-compliant workload provisioning for state-affiliated institutions. It offers a solid foundation for clients, ensuring simplicity, compliance, and top-tier security for sensitive data.

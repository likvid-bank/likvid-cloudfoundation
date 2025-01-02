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

## Implementation

### 1. Setting up STACKIT

1. Create a STACKIT account through the [STACKIT Portal](https://stackit.de).
2. Set up API credentials for your organization to enable meshStack integration.

### 2. Integrating STACKIT as a Cloud Platform

1. Navigate to the platform team’s workspace:
   - `${meshobjects_import_workspaces_stackit_yml_output_spec_displayName}`.
2. Create a Building Block Definition for STACKIT:
   - **Name:** `${buildingBlockDefinitions_stackit_virtual_datacenter_spec_displayName}`.
   - **Inputs:**
     - `region`: Selected STACKIT region (e.g., Germany, Austria).
     - `project_name`: The name of the project where workloads will be deployed.
     - `resources`: Resource configuration (e.g., VMs, storage, or Kubernetes).
   - **Outputs:**
     - `stackit_project_id`: ID of the created project in STACKIT.
     - `web_console_url`: URL to access the STACKIT project.

3. Define a new Cloud Platform in meshStack:
   - **Name:** `${platformDefinitions_stackit_spec_displayName}`.
   - **Type:** STACKIT Secure Cloud Platform.
   - **Description:** `${platformDefinitions_stackit_spec_description}`.

### 3. Publish the Platform

1. Create Landing Zones for different use cases:
   - `${landingZones_stackit_dev_spec_displayName}` for development environments.
   - `${landingZones_stackit_prod_spec_displayName}` for production workloads.
2. Publish the STACKIT platform in the meshStack marketplace to make it available for application teams.


---

## Conclusion

By following this guide, Likvid Bank provides a European cloud solution via meshStack, enabling DSGVO-compliant workload provisioning for state-affiliated institutions. It offers a solid foundation for clients, ensuring simplicity, compliance, and top-tier security for sensitive data.

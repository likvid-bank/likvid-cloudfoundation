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

### 2. Configure STACKIT Projects in meshStack

#### Create a Custom Building Block Definition

1. Create a new Building Block Definition with the following configuration:
   - **Implementation Type**: Terraform
   - **Git Repository URL**: `git@github.com:likvid-bank/likvid-cloudfoundation.git`
   - **Git Repository Path**: `kit/stackit/buildingblocks/projects/buildingblock`
   - **Inputs**:
     - `api_url`: The STACKIT API URL.
     - `token`: The token from your service account.
     - `workspace_id`: Workspace ID for the STACKIT environment; select it as a type in meshStack.
     - `project_id`: Project ID where workloads will be deployed; select it as a type in meshStack.
     - `parent_container_id`: The parent container for resource organization.
     - `users`: User access configuration; select it as a type in meshStack.
   - **Outputs:**
     - `tenant_id`: The unique ID of the created project in STACKIT.
     - `stackit_login_link`: URL for accessing the STACKIT project.

#### Set Up a Custom Platform

1. Create a new Custom Platform called:
   ```bash
   ${platformDefinitions_stackit_spec_displayName}
   ```

2. Configure the following parameters:
   - **Description**: `${platformDefinitions_stackit_spec_description}`
   - **Web Console URL**: `${platformDefinitions_stackit_spec_web_console_url}`
   - **Support URL**: `${platformDefinitions_stackit_spec_support_url}`
   - **Documentation URL**: `${platformDefinitions_stackit_spec_documentation_url}`

3. Define Landing Zones for Development and Production environments:
   - Development:
     ```bash
     ${landingZones_stackit_dev_spec_displayName}
     ```
   - Production:
     ```bash
     ${landingZones_stackit_prod_spec_displayName}
     ```

### 3. Publish  STACKIT Projects building block

1. Navigate to the Landing Zone configuration:
   - Link the Building Block Definition `${buildingBlockDefinitions_stackit_projects_spec_displayName}` to the Landing Zones for both development and production.
2. Publish the Custom Platform:
   - Ensure that the platform appears in the meshStack marketplace.
3. Submit the platform for administrator review and approval.

---

## Conclusion

By following this guide, Likvid Bank provides a European cloud solution via meshStack, enabling DSGVO-compliant workload provisioning for state-affiliated institutions. It offers a solid foundation for clients, ensuring simplicity, compliance, and top-tier security for sensitive data.

# IONOS Custom Platform: Likvid Government Guard

This guide explains how to manage and provision secure workloads for government clients using the Likvid Government Guard platform, hosted in the IONOS Cloud. The platform emphasizes DSGVO compliance, high-level security, and exclusivity for state-affiliated institutions and their employees.

---

## Motivation

At Likvid Bank, the Platform team is tasked with creating an exclusive service for state-affiliated clients who handle sensitive data and operate under strict regulatory environments. Likvid Government Guard leverages the IONOS Cloud to provide:

- **DSGVO Compliance**: Ensuring all hosted data complies with the European Union’s General Data Protection Regulation.
- **Enhanced Security**: Offering preconfigured compliance settings and secure access for government-affiliated users.
- **Custom Access Zones**: Tailored environments for authorized users with distinct roles and privileges.

---

## Challenges

The Platform team has identified the following challenges in deploying Likvid Government Guard:

- **Ease of Use:** Ensuring discoverability and usability of the custom platform via meshStack’s marketplace.
- **Compliance** Enforcing compliance policies and high-security standards through automated configurations.
- **Self-Service** Providing seamless onboarding and management for application teams, ensuring ease of use and consistency.

---

## Implementation

### 1. Set Up IONOS Cloud Access

1. **IONOS Account Creation**:
   - create a new contract in the [partner portal](https://partner.ionos.com). It is not possible to creating the same Users in different Contracts.
   - In the subcontract, an admin user is created, which can be used to interact with the building block via Terraform.
     Therefore, it unfortunately only makes sense to provide individual environments such as a DCD or a cluster within a single contract and not to issue subcontracts to the respective requesters.
     All users must be created in the contract beforehand. Replication of users via SSO does not work.

### 2. Configure Ionos DCD in meshStack

#### Create a Custom Building Block Definition

1. Navigate to the "Service Management Area" in the Platform team’s workspace:
   ```bash
   ${meshobjects_import_workspaces_ionos_yml_output_spec_displayName}
   ```

2. Create a new Building Block Definition with the following configuration:
   - **Implementation Type**: Terraform
   - **Git Repository URL**: `git@github.com:likvid-bank/likvid-cloudfoundation.git`
   - **Git Repository Path**: `kit/ionos/buildingblocks/virtual-datacenter/buildingblock`
   - **Inputs**:
     - `location`: the location is hardcoded because we only allow "de/fra".
     - `workspace_identifier`: The meshStack workspace identifier (source).
     - `project_identifier`: The meshStack project identifier (source).
     - **Terraform Backend (AWS):**
       - `aws_account_id`: AWS account ID for the assume role where the backend was created (part of `provider.tf`).
       - `AWS_ACCESS_KEY_ID`: AWS IAM user access key (environment variable).
       - `AWS_SECRET_ACCESS_KEY`: AWS IAM user secret access key (environment variable, encrypted).
     - **IONOS Cloud Credentials**:
       - `IONOS_USERNAME`: Username for the IONOS Cloud (environment variable).
       - `IONOS_PASSWORD`: Password for the IONOS Cloud (environment variable, encrypted).
     - `vdc_name`: Name of the Virtual Data Center.
   - **Outputs**:
     - `tenant_id`: ID of the created Virtual Data Center (**Assignment Type**: Platform Tenant ID).
     - `ionos_dcd_login_link`: URL for managing the Virtual Data Center.

#### Set Up a Custom Platform

1. Create a new Custom Platform called:
   ```bash
   ${platformDefinitions_ionos_spec_displayName}
   ```

2. Configure the following parameters:
   - **Description**: `${platformDefinitions_ionos_spec_description}`
   - **Web Console URL**: `${platformDefinitions_ionos_spec_web_console_url}`
   - **Support URL**: `${platformDefinitions_ionos_spec_support_url}`
   - **Documentation URL**: `${platformDefinitions_ionos_spec_documentation_url}`

3. Define Landing Zones for Development and Production environments:
   - Development:
     ```bash
     ${landingZones_ionos_dev_spec_displayName}
     ```
   - Production:
     ```bash
     ${landingZones_ionos_prod_spec_displayName}
     ```

---

### 3. Publish Ionos Virtual Datacenter building block

1. Navigate to the Landing Zone configuration:
   - Link the Building Block Definition `${buildingBlockDefinitions_ionos_virtual_datacenter_repository_spec_displayName}` to the Landing Zones for both development and production.
2. Publish the Custom Platform:
   - Ensure that the platform appears in the meshStack marketplace.
3. Submit the platform for administrator review and approval.

---

### 4. Application Teams Consuming the Service

1. Application teams navigate to the meshStack marketplace and select the platform:
   ```bash
   ${platformDefinitions_ionos_spec_displayName}
   ```

2. A Virtual Data Center is created within the IONOS Cloud, linked to the specific project:
   ```bash
   Development: ${meshstack_project_likvid_gov_guard_dev_spec_display_name}
   Production: ${meshstack_project_likvid_gov_guard_prod_spec_display_name}
   ```
4. The application team receives access to the Virtual Data Center via a secure login link:
   ```bash
   ${platformDefinitions_ionos_spec_web_console_url}
   ```

---

## Conclusion

By following this guide, the Likvid Government Guard platform enables secure, DSGVO-compliant workload provisioning for state-affiliated institutions. Hosted on the IONOS Cloud, it provides a robust foundation for government clients while ensuring simplicity, compliance, and high-level security for sensitive data.

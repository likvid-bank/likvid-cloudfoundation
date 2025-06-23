# SAP BTP as a Custom Platform

This guide explains how to manage SAP BTP services as a custom platform that can be consumed by application teams using meshStack.

---

## Motivation

At Likvid Bank, the Platform team is tasked with building the organization’s internal developer platform. One of the foundational services they aim to offer is self-service provisioning and management of SAP BTP subaccounts. The team has defined key requirements to ensure compliance while simplifying workflows for application teams:

- **Secure**: Ensure subaccounts are created with preconfigured compliance settings, such as security policies and access restrictions.
- **Flexible**: Allow application teams to choose from predefined subaccount configurations or create custom subaccounts based on their specific requirements.

---

## Challenges

The Platform team has identified the following challenges:

- Making the custom subaccount service easily discoverable through meshStack’s marketplace.
- Enforcing secure access and compliance policies by applying standardized tags, roles, and policies during subaccount creation.
- Providing clear guidance and feedback to users during the subaccount provisioning process, ensuring ease of use and consistency.

## Integrating SAPBTP with meshStack

### 1. Set Up SAP

1. **Create a SAP Account**
   - Create a [SAP Universal ID](https://account.sap.com/core/create) for logging into SAP.
2. **Create a User**
   - Create a user with permissions for creating subaccounts in your BTP Cockpit. Terraform will use this user to create the infrastructure.
   - Set a password for the user, as it is required for the Terraform SAP BTP Provider.

---

### 2. Configure SAPBTP Subaccounts in meshStack

#### Create a Custom Building Block Definition

1. Navigate to the "Platform Builder" of the ${md_workspace_sap_core_platform} workspace.
2. Create a new Building Block Definition called `${buildingBlockDefinitions_sapbtp_subaccounts_repository_spec_displayName}`.
3. Set up the necessary parameters for the Building Block Definition:
   - **Implementation Type**: Terraform
   - **Git Repository URL**: `git@github.com:likvid-bank/likvid-cloudfoundation.git`
   - **Git Repository Path**: `kit/sapbtp/buildingblocks/subaccounts/buildingblock`
   - **Inputs**:
     - `globalaccountd`: The subdomain of the global account in which you want to manage resources (static source).
     - `region`: The region of the subaccount (static source, as only one region is allowed).
     - `workspace_identifier`: The meshStack workspace identifier (source).
     - `project_identifier`: The meshStack project identifier (source).
     - **Terraform Backend (AWS):**
       - `aws_account_id`: AWS account ID for the assume role where the backend was created (part of `provider.tf`).
       - `AWS_ACCESS_KEY_ID`: AWS IAM user access key (environment variable).
       - `AWS_SECRET_ACCESS_KEY`: AWS IAM user secret access key (environment variable, encrypted).
     - `parent_id`: The ID of the parent resource in the SAP BTP Portal.
     - `users`: The [User Permissions](https://docs.meshcloud.io/docs/administration.building-blocks.html#user-permissions) that grant access to the created subaccount.
     - **SAP BTP:**
       - `BTP_USERNAME`: Username for creating subaccounts in BTP (environment variable).
       - `BTP_PASSWORD`: Password for creating subaccounts in BTP (environment variable, encrypted).
   - **Outputs**:
     - `btp_subaccount_login_link`: URL for the cockpit login to the created subaccount.
     - `btp_subaccount_id`: The full name of the created subaccount (**Assignment Type**: Platform Tenant ID).
4. Create a new Custom Platform called `${platformDefinitions_sap_core_platform_spec_displayName}`.
5. Select an appropriate platform type (e.g., SAP BTP). If unavailable, create a new platform type at this step.
6. Configure the necessary parameters for the Custom Platform:
   - **Description**: `${platformDefinitions_sap_core_platform_spec_description}`
   - **Web Console URL**: `${platformDefinitions_sap_core_platform_spec_web_console_url}`
   - **Support URL**: `${platformDefinitions_sap_core_platform_spec_support_url}`
   - **Documentation URL**: `${platformDefinitions_sap_core_platform_spec_documentation_url}`

### 3. Publish the SAP BTP Service

1. In the Custom Platform, create a Landing Zone `${landingZones_sap_core_platform_spec_displayName}` that uses the Building Block Definition `${buildingBlockDefinitions_sapbtp_subaccounts_repository_spec_displayName}` as a mandatory building block.
2. Publish the new Custom Platform to make it available in the meshStack marketplace.
3. An administrator will review and approve publishing the Custom Platform.


#### Set Up a Custom Platform

1. Create a new Custom Platform called:

   ```bash
   ${ platformDefinitions_sap_core_platform_spec_displayName }
   ```
2. Configure the following parameters:
   - **Description**: `${platformDefinitions_sap_core_platform_spec_description}`
   - **Web Console URL**: `${platformDefinitions_sap_core_platform_spec_web_console_url}`
   - **Support URL**: `${platformDefinitions_sap_core_platform_spec_support_url}`
   - **Documentation URL**: `${platformDefinitions_sap_core_platform_spec_documentation_url}`

3. Define a Landing Zone:

     ```bash
     ${landingZones_sap_core_platform_spec_displayName}
     ```


### 4. Publish SAPBTP Subaccounts building block

1. Navigate to the Landing Zone configuration:
   - Link the Building Block Definition `${buildingBlockDefinitions_sapbtp_subaccounts_repository_spec_displayName}` to the Landing Zone.
2. Publish the Custom Platform:
   - Ensure that the platform appears in the meshStack marketplace.
3. Submit the platform for administrator review and approval.

### 5. Application Team Consuming the Service

1. The application team has the workspace ${md_workspace_sap_core_platform} and project ${md_project_sap_core_platform}.
2. The application team navigates to the meshStack marketplace and selects the ${platformDefinitions_sap_core_platform_spec_displayName} platform.
3. They provide the necessary inputs and submit the request.
4. A tenant M25 SAP is created for the [M25 Platform Team](md_workspace_m25_platform_team) as their subaccount.
5. The [M25 Platform Team](md_workspace_m25_platform_team) can now access the SAP BTP subaccount through the created tenant via "Sign in to Web Console" and start working on their project.

## Conclusion
By following this guide, teams can publish custom services using meshStack's Custom Platform functionality,
making them discoverable and consumable by other teams. This ensures seamless integration and management of
custom services within the meshStack ecosystem.

# SAPBTP as a Custom Platform

This guide shows you how to manage SAP BTP services as a custom platform that can be consumed by Application teams
using meshStack.

# Motivation

At Likvid Bank, the Platform team is tasked with building the organization’s internal developer platform. One of the foundational services they aim to offer is self-service provisioning and management of SAP BTP subaccounts.
The team has defined key requirements to ensure compliance while simplifying workflows for Application teams:

- Secure: Ensure subaccounts are created with preconfigured compliance settings, such as security policies and access restrictions.
- Flexible: Allow Application teams to choose from pre-defined subaccount configurations or create custom subaccounts based on their specific requirements.

# Challenges

The Platform team has identified the following challenges:

- Making the custom subaccount service easily discoverable through meshStack’s marketplace.
- Enforcing secure access and compliance policies by applying standardized tags, roles, and policies during subaccount creation.
- Providing clear guidance and feedback to users during the subaccount provisioning process, ensuring ease of use and consistency.

## Implementation

### 2. Setting Up a Custom Platform

### 3. Publishing the SAPBTP Custom Service

### 4. Application Team Consuming the Service

1. The Application team has the following workspace, project:
   ```bash
   Workspace ``
   └── Project ``
   ```
2. The Application team navigates to the meshStack marketplace and selects `` platform.
3. They provide the necessary inputs (e.g., repository name, template repo) and submit the request.
4. A tenant `` is created for the Application team, which is their GitHub repository.
5. The Application team can now access the GitHub repository through the created tenant via "Sign in to Web Console" and start working on their project.
6. The Application team are also given more information through buildingblock outputs like `` so they can clone the repository to their local machine.

## Conclusion

By following this guide, teams can publish custom services using meshStack's Custom Platform functionality,
making them discoverable and consumable by other teams. This ensures a seamless integration and management of
custom services within the meshStack ecosystem.

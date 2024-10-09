locals {
  guide_custom_platforms = <<EOF
# GitHub Repository as a Custom Platform

This guide shows you how to publish a GitHub repository service as a custom platform that can be consumed by Application teams
using meshStack.

## Motivation

Likvid Bank has a `${terraform_data.meshobjects_import["workspaces/devops-platform.yml"].output.spec.displayName}` team. Their job is to build Likvid Bank's internal developer platform.
The first and essential service they want to offer for their platform is GitHub repositories.

The first thing they did was defining requirements to stay compliant while also making Application teams' life easier.

- Secure: vulnerability alerts are always activated on new repositories.
- Flexible: application teams can choose from ready templates (code scaffoldings) to expedite development, but can also create a repository from scratch.

## Challenges

The Platform team has identified the following challenges:

- Making the custom service discoverable via meshStack's marketplace.
- Ensuring secure and controlled access to the custom service via tags and policies.
- Providing detailed user feedback and documentation.

## Implementation

### 1. Setup GitHub App

1. [Register a GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app) with admin permissions
2. [Create a key](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/managing-private-keys-for-github-apps)

### 2. Setting Up a Custom Platform

1. Navigate to the "Service Management Area" of the Platform team's workspace: `${terraform_data.meshobjects_import["workspaces/devops-platform.yml"].output.spec.displayName}`.
2. Create a new Building Block Definition called `${local.buildingBlockDefinitions.github-repository.spec.displayName}`.
3. Set up the necessary parameters for the Building Block Definition
  - Implementation Type: Terraform
  - Git Repository URL: git@github.com:likvid-bank/likvid-cloudfoundation.git
  - Git Repository Path: kit/github/buildingblocks/repository/buildingblock
  - Inputs that align with the buildingblocks terraform variables + necessary GitHub App inputs that is setup in [Step 1](#1-setup-github-app):
    - `github_app_id`: The GitHub App ID.
    - `github_app_pem`: The GitHub App PEM file content. (Make sure to select encrypted when setting this input)
    - `github_app_installation_id`: The GitHub App Installation ID.
  - Outputs that align with the buildingblocks terraform outputs:
    - `repo_name`: The name of the created repository.
    - `repo_full_name`: The full name of the created repository. IMPORTANT: Assignment Type for this output should be `Platform Tenant ID`.
    - `repo_html_url`: The HTML URL of the created repository. IMPORTANT: Assignment Type for this output should be `Sign In Url`.
    - `repo_git_clone_url`: The Git clone URL of the created repository.
4. Create a new Custom Platform called `${local.customPlatformDefinitions.github-repository.spec.displayName}`.
5. Select an appropriate platform type (e.g., GitHub). If you do not have one, you can create a new platform type in this step.
6. Configure the necessary parameters for the Custom Platform:
    - `Description`: `${local.customPlatformDefinitions.github-repository.spec.description}`
    - `Web Console URL`: `${local.customPlatformDefinitions.github-repository.spec.web-console-url}`
    - `Support URL`: `${local.customPlatformDefinitions.github-repository.spec.support-url}`
    - `Documentation URL`: `${local.customPlatformDefinitions.github-repository.spec.documentation-url}`

### 3. Publishing the GitHub Repository Service

1. In the Custom Platform, create a Landing Zone `${local.landingZones.github-repository.spec.displayName}` that uses the Building Block Definition `${local.buildingBlockDefinitions.github-repository.spec.displayName}` as a Mandatory Building Block.
2. Publish the new Custom Platform to make it available in meshStack marketplace.
3. An Admin will review and approve publishing the Custom Platform.

### 4. Application Team Consuming the Service

1. The Application team has the following workspace, project:
   ```bash
   Workspace `${terraform_data.meshobjects_import["workspaces/m25-online-banki.yml"].output.spec.displayName}`
   └── Project `${meshstack_project.m25_online_banking_app.spec.display_name}`
   ```
2. The Application team navigates to the meshStack marketplace and selects `${local.customPlatformDefinitions.github-repository.spec.displayName}` platform.
3. They provide the necessary inputs (e.g., repository name, template repo) and submit the request.
4. A tenant `${meshstack_tenant.m25_online_banking_app_docs_repo.spec.local_id}` is created for the Application team, which is their GitHub repository.
5. The Application team can now access the GitHub repository through the created tenant via "Sign in to Web Console" and start working on their project.
6. The Application team are also given more information through buildingblock outputs like `repo_git_clone_url` so they can clone the repository to their local machine.

## Conclusion

By following this guide, teams can publish custom services using meshStack's Custom Platform functionality,
making them discoverable and consumable by other teams. This ensures a seamless integration and management of
custom services within the meshStack ecosystem.
EOF
}

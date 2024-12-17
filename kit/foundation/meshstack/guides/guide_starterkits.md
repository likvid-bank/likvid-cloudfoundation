# Composing Building Blocks and Tenants into Starter Kits

This guide will walk you through the process of creating a starter kit building block.
A starter kit is designed to bundle together tenants and building blocks, offering a robust foundation for project teams to kickstart their initiatives effectively.

## Motivation

While a single building block can certainly encapsulate multiple resources, providing individual components as separate building blocks offers several advantages.
This approach facilitates better code reuse without duplication and promotes separation of concerns, enabling different teams to manage distinct parts of the system independently.
Additionally, this method enhances transparency for users, as individual building blocks making up a starter kit will be shown in the panel.

## Implementing an "Azure Starter Kit"

As an example we will look at a starter kit that integrates an existing project with an Azure subscription with GitHub by

- Creating a new GitHub repository using a landing zone with mandatory building block.
- Configuring the repository to run GitHub Action workflows with access to the Azure subscription.

### 1. Enable GitHub repository tenant creation

Configure a basic GitHub platform as described [here](/meshstack/guides/guide_custom_platforms.md).

Afterwards we need to duplicate the `${buildingBlockDefinitions_github_repository_spec_displayName}` building block.
Name it `${buildingBlockDefinitions_github_repository_spec_displayName} for Starter Kit`.
We replace all user inputs with static values or let meshStack provide them:

- `repo_name`: Source from project identifier.
- `repo_description`: Static string (`Created by Azure Starter Kit`).
- `repo_visibility`: Static string, private by default (`private`).
- `use_template`: We want to provide an example of a GitHub Action. Static boolean (`true`).
- `template_owner`: Static string (`likvid-bank`).
- `template_repo`: Static string (`starterkit-template-azure-static-website`).

Afterwards we duplicate the landing zone for use with our starter kit (name it `${landingZones_github_repository_spec_displayName} for Starter Kit`) and change the mandatory building block to `${buildingBlockDefinitions_github_repository_spec_displayName} for Starter Kit`.

Now we have a building block and landing zone for creating GitHub repositories without requiring additional user inputs.

### 2. Create GitHub Action Integration Buliding Block Definition

Next we create a building block definition for connecting GitHub Actions to Azure, this building block will create a number of resources:

- Roles and service principles for use with GitHub Actions.
- Credentials as a GitHub secret.
- Storage for Terraform state.
- Terraform config files in the repo.

The building block inputs should be sourced as follows:

- `repo_name`: from user input.
- `workspace_identifier`: from workspace identifier.
- `project_identifier`: from project identifier.
- `subscription_id`: from platform tenant id.
- `config.tf`: encrypted static file generated by the backend module.
- `likvid-bank-devops-toolchain-team.private-key.pem`: encrypted file containing the GH App private key.

This building block already provides value on its own and can be used with any Azure subscription and GitHub repository.

### 3. Create Starter Kit Building Block Definition

All that remains is to create a building block definition for the starter kit itself, name it `Starter Kit - GitHub Actions`.
Deletion mode should be set to purge.

Set the following inputs:

- `workspace_identifier`: from workspace identifier.
- `project_identifier`: from project identifier.

Additionally, we must provide an encrypted `config.tf` with meshStack API keys for all workspaces this building block should be able to work on.
This is a temporary workaround that is required until there is a way to manage tenants and building blocks in all workspaces with API keys.

```hcl
locals {
  api_credentials = {
    workspace-one = {
      key    = "e2c1efff-8494-488e-89f2-e97b8724f58e"
      secret = "..."
    }
    workspace-two = {
      key    = "3b6d7fee-46be-4ca4-954c-3603c924a4a2"
      secret = "..."
    }
  }
}
```

### Result

In conclusion, you will have:

- A GitHub platform for provisioning new repositories.
- A building block specifically designed to connect GitHub repositories to Azure subscriptions.
- A starter kit that bundles both of these components together.
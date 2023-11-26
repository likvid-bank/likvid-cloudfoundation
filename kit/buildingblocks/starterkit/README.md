---
name: Starter Kits
summary: |
  Offers templates for application teams to get started quickly with deploying their applications on the cloud while following best practices.
compliance:
- control: compliance/cfmm/service-ecosystem/managed-devops-toolchain
  statement: |
    Provides a GitHub repository set up to deploy against Azure Subscriptions using Workload Identity Federation.
- control: compliance/cfmm/iam/service-account-management
  statement:  |
    Automatically manages service principals for CI/CD pipelines using Workload Identity Federation.
---

# Starter Kits

This is an implementation of "Cloud Starter Kits" that provides application teams with

- a GitHub repository, seeded with an application starter kit
- a GitHub actions pipeline
- a service account solution that enables the GitHub actions pipeline to deploy to your Azure Subscription

## Structure of this Kit module

This kit module comes with two parts

- the kit module itself, acting as the building block's "backplane" that sets up all required infrastructure for deploying starterkits for application teams
- a terraform module that forms the definition for each "building block", i.e. the instance of the starterkit deployed for a particular application team
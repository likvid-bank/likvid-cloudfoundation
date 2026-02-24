# meshKube: Kubernetes based Internal Developer Platform

This demo story shows how Likvid Bank’s Platform Engineer **Phil** and
Application Engineer **Adam** use **meshKube** to bridge the gap between
platform operations and developer agility—enabling faster, more consistent
Kubernetes deployments through a unified Internal Developer Platform (IDP).

## Motivation / Business Context

Likvid Bank runs hundreds of microservices across Azure Kubernetes Service.

The Platform Engineering team ${md_workspace_devops_platform}, led by **Phil**
is responsible for maintaining secure, standardized, and compliant
infrastructure. Meanwhile, application teams like **Adam’s**
${md_workspace_payments_api} team need to move quickly—deploying new services,
creating test environments, and experimenting safely.

Before meshKube, both sides were stuck in a cycle of manual work and
misalignment.

App teams opened tickets for every environment change; platform engineers had to
dig through Terraform code and YAML pipelines to support them. Each team
maintained its own Infrastructure-as-Code (IaC) flavor, leading to inconsistent
setups, drift, and lost time on both ends.

To regain speed and consistency, Likvid Bank’s group set out to build an
Internal Developer Platform. Instead of assembling it piece by piece, they
adopted **meshKube** to fast-track the rollout and connect developers directly
to standardized Kubernetes infrastructure.

## Challenges

**1. IaC fragmentation and drift**

Each product team used its own Terraform and Helm modules, resulting in “IaC
snowflakes” that were hard to scale and prone to drift whenever shared modules
changed.

**2. Pipeline complexity**

The company’s CI/CD pipelines had grown into a dense web of YAML files that only
a few engineers understood. This slowed down deployments and made enforcing
standards difficult.

**3. Manual requests and slow provisioning**

Every new environment or configuration update required a ticket to the platform
team, creating bottlenecks and blocking development velocity.

**4. Developer expectations outpacing platform capacity**

Developers wanted instant, self-service provisioning and a golden path that
connects their most important tools. The platform team, meanwhile, was bogged
down maintaining tooling rather than delivering new features.

**5. Building an IDP takes too much time**

Constructing a custom platform from scratch proved to be a long, ongoing
effort—competing with daily incidents, audits, and internal demands.

## Implementation Steps

### Overview of the Application Team Experience

Note: The following steps have already been performed by the application
engineer **Adam** in the ${md_workspace_payments_api} workspace. To simulate
starting in an empty workspace use ${md_workspace_empty}. instead.

#### Locating the Golden Path

1. Adam logs into meshStack and opens his workspace. Since he doesn't have any
   resources yet, the portal suggest browsing the marketplace.
2. Adam is presented with a curated list of building blocks published by the
   platform team, but since he doesn't know exactly what he needs, he uses the
   "Get help" feature to open a chat with meshStack Copilot, the platform's AI
   assistant.
3. Adam describes his requirements to Copilot: "I need to build a new app on
   kubernetes"
4. Copilot suggests several building blocks that match Adam's needs, including
   ${buildingBlockDefinitions_aks_starterkit}.
5. Adam reviews the Readme of this service, and especially looks at the Shared
   Responsibility Matrix. The he clicks "Add to Workspace".

#### Provisioning

After creation, meshKube automatically launches the provisioning workflow.

- Within about two minutes, the automation completes and a **summary** appears.
- The summary lists the created objects - a dev and prod projects, each with its
  own namespace and linked GitHub repository.
- It also provides a short guide on how to get started with the included
  **Angular** and **Node.js** applications and deploy them.

#### Exploring the Created Resources

Open the **Workspace Overview** tab for a complete view of all workspace
components.

- The overview displays every created object with **direct links** to connected
  systems such as GitHub repositories and Kubernetes namespaces.
- The AKS Starterkit contains a “Dev App” link that links to the deployed
  development app which allows immediate validation that the **Angular
  frontend** is running and connected to its **Node.js backend**.

This provides a transparent, unified view of the entire environment.

#### Developer Workflow

From the workspace overview, open the linked GitHub repository.

- The repository contains pre-configured **Angular** and **Node.js** source
  code, along with a ready-to-use CI/CD pipeline.
- Make a simple change—for example, update the greeting message in
  `backend/index.js` at line 24—and commit it.
- The CI/CD pipeline automatically runs, builds, and redeploys the updated
  application.
- Within minutes, the changes are live and verifiable in the running app. 🎉

This demonstrates a fully automated developer workflow built on top of
standardized platform components.

### Components of the meshKube Internal Developer Platform

#### Key Concept: Building Blocks

A building block is the smallest reusable automation component in meshStack.
Building blocks have inputs, an automation implementation like terraform, and
outputs.

Building blocks can be composed into graphs via dependencies and allow you to
create complex platforms.

#### The GitHub Repository

The simplest building block in meshKube is the GitHub Repository building block.
It creates a GitHub repository from a template that contains the source code for
the sample applications and the CI/CD pipeline.

#### The AKS Cluster and Namespaces

A pattern that platform engineers need to implement often is to have cloud
platform "tenants" that have their own lifecycle. Many building blocks will
depend on them. In meshStack we have "tenants", which you can think of as a base
plate for other building blocks to live on.

In meshKube we have a building block that creates a namespace in an existing AKS
cluster, and we create two of those

- one for development and one for production.

#### Dependency Graph

The platform engineers want to provide a true golden path that helps application
teams get started quickly and include CI/CD best practices such as

- hosting containers in Likvid Banks' private container registry
- securely connecting from the CI/CD pipeline to the AKS cluster without manual
  secrets management

To achieve this, they add a "GitHub Actions to AKS" building block that manages
a Kubernetes Service Account and makes it available as a GitHub secret in the
created repository. This building block has a dependency on the GitHub
Repository and lives on each AKS Namespace tenant. This makes the structure
visible.

#### Compositions

To simplify consumption, the platform engineers create a composition building
block called "AKS Starterkit". This building block has no implementation of its
own but instead combines the previously described building blocks into a single
unit.

Compositions in meshStack use terraform modules under the hood to define how
building blocks are composed. This is a simple and elegant mechanism that
platform engineers can use to create higher-level abstractions without diving
into YAML hell.

## Conclusion

By following these steps, platform teams can successfully integrate their
existing GitLab CI/CD pipelines with meshStack. This approach allows them to
leverage their current automation investments while providing a standardized and
governed self-service experience for consuming these services through meshStack.
Application teams benefit from easy access to established components like static
website hosting, provisioned through familiar meshStack building blocks, thereby
accelerating their development cycles and ensuring compliance.

locals {
  guide_on_premises_connectivity = <<EOF
# On Premises Connectivity

This guide shows you how you can solve common integration challenges for enabling on-premises Connectivity with meshStack.

## Motivation

The Market Analytics Team of Likvid Bank is handling a significant volume of market data through a sophisticated cloud-based application. This application employs advanced algorithms to analyze market trends and deliver valuable insights. By hosting the application in the cloud, the team benefits from the scalability and flexibility that cloud services provide.

However, the raw market data required by the application resides in an on-premises data center. This data is continually updated through various data feeds and is stored in a high-performance data warehouse. Due to the sensitive nature of the data and regulatory and compliance constraints, it cannot be transferred to the cloud.

The primary challenge for the Market Analytics Team is establishing a secure and efficient connection between their cloud-based application and the on-premises data center. They need a solution that allows the application to retrieve necessary data from the on-premises data warehouse, process it in the cloud, and then store the results back in the data warehouse.

This guide will demonstrate how the team can utilize meshStack to address this challenge. By leveraging meshStack's features such as Building Blocks (BBs), Landing Zones (LZs), and the meshStack Terraform provider, the team can establish secure connectivity between their cloud application and the on-premises data center. This ensures that their application can access the required data while adhering to all regulatory requirements.

## Challenges

The Cloud Foundation team, in collaboration with the Market Analytics Team, has identified the following milestones:

- Establish secure connectivity between the cloud-based application and the on-premises data center. This responsibility lies with the Cloud Foundation team.

- The Market Analytics Team will gain access to a meshStack workspace, where they will create a project and tenant for the Market Data Connector application. This is their responsibility. The Team intends to employ Infrastructure as Code (IaC) principles, in conjunction with DevOps practices, to deploy both the meshStack projects/tenants and the Market Data Connector application, ensuring adherence to best practices.

- The deployment of the Application will be managed through a CI/CD pipeline using GitHub Actions and federated identity access.

- The Market Data Analytics Team will maintain comprehensive documentation for the Market Data Connector application in their GitHub repository.

## Implementation

### Handled by the Cloud Foundation Team

Setting Up the Building Block Automation and Backplane

The first step towards integrating the Hub and Spoke architecture is to set up the Building Block Automation (tfstate storage, permissions, spn) and the Backplane that each building block comes with.

:::tip Building Block Automation and Backplane
The Building Block Automation is a one-time setup and will be used by all the building blocks, not only the vNet peering. The Backplane is more individual for each building block because different permissions are used. For a more detailed guide on how to set up the Building Block Backplane, please refer to the [meshStack documentation](https://docs.meshcloud.io/docs/meshstack/latest/guides/building-blocks/backplane).
:::

### Setting Up Building Block Definition

Therefore, setting up a Building Block Definition in meshStack is necessary. The connectivity Building Block is a mandatory Building Block on the Corporate Landing Zone.
It's not possible yet to make the VNet Building Block Definition mandatory when it needs User or Operator inputs when the tenant is created via Terraform.

:::tip Building Block Definition
For more information on how to set up a Building Block Definition, please refer to the [meshStack documentation ](https://docs.meshcloud.io/docs/administration.building-blocks.html#creating-a-new-building-block-definition).
:::

### Workspace Access for the Market Analytics Team

The Cloud Foundation team will provide the Market Analytics Team with access to a meshStack workspace. This workspace will be used by the Market Analytics Team to create a project and tenant for the Market Data Connector application.

### Handled by the Market Analytics Team

### API Key Creation for Workspace and deployment via terraform

The Market Analytics Team will create an API key for the workspace. This API key will be used to authenticate with meshStack and access the resources to create the tenant and project via the meshStack Terraform provider. The Terraform code will be stored in the Market Data Connector GitHub repository.

:::tip meshStack Terraform Provider
Here you can find our [meshStack Provider](https://registry.terraform.io/providers/meshcloud/meshstack/latest/docs)
:::

### Deployment of the Market Data Connector Application

The Market Analytics Team will deploy the Market Data Connector application using the meshStack and the Azure Terraform provider. The Application is written in Python and will be deployed as an Azure Web App. The application will pull market data from the on-premises data warehouse to the cloud. The entire infrastructure and application setup is managed by a Github Action CI/CD Pipeline. You can find the whole project with more details here:

:::tip Repo and Documentation
[Market Data Connector Project](https://github.com/likvid-bank/marketdata-connector/tree/main)
:::

EOF
}

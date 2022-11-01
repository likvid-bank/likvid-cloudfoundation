# likvid-prod-alz

Building a landing zone in Azure can be a daunting task, especially since Microsoft provides various options to pursue, from Azure resource manager (ARM) templates to Terraform modules. If you’d like to see how the different ways compare, check out our [Azure landing zone comparison](https://www.meshcloud.io/2022/09/27/azure-landing-zone-comparison/) blog post. In the end, any approach will implement the Azure landing zone conceptual architecture (also called enterprise scale in other contexts), or part of it:

![image](https://user-images.githubusercontent.com/96071919/199272145-0524367e-5d7f-4f91-9ed2-29e12078c129.png)


That already seems like a lot, doesn’t it? Certainly not something that a solo Platform Engineer or an Enterprise Architect will find easy to do. But that’s fine, since Azure already has a ready-to-use Terraform module that will create the baseline of that architecture (image below).

![image](https://user-images.githubusercontent.com/96071919/199272328-25a0e6b0-4f1f-4824-9b77-08776c1e6ed8.png)

There are many reasons to start out with [Azure landing zones Terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki):

- Microsoft recommends it for most organizations.
- It is lightweight, and quick to deploy.
- Their repository includes a Wiki with detailed examples to use.
- It paves your way to adopting GitOps from the get go.
- It prepares your landing zones setup for scale.

There remain open questions that are not covered by only using this module:

- How can I store the terraform state of this module?
- How can I restrict access to the terraform state file to specific users?
- As a Platform Engineer or an Enterprise Architect, I have other resources I want to include to my cloud foundation that are not covered by this module, how can I do that?

These questions are answered by the previously mentioned [Landing Zone Construction Kit](https://github.com/meshcloud/landing-zone-construction-kit). In the next section, we’ll explain how to use this tool to become the new superhero by setting up a new Landing Zone with only a few quick commands.

## Let's Start

### Prerequisites
Before building landing zones we will need to have the following:
- An Azure subscription
- A high privileged user (With `Global Administrator` role and `User Access Admin` on the root management group)
- AZ cli
- Terraform
- Terragrunt

### Preparation
Follow [collie-cli installation guidelines](https://github.com/meshcloud/collie-cli#-installation) to install `collie-cli/`. After that, we will check that collie works properly.
```bash
collie -V
```
After installing collie and its required dependencies, login with az cli to the AAD tenant where you will deploy your landing zones.
```bash
az login --tenant <aadTenantPrimaryDomain>
```

### Configuration
1- **New Foundation**
Create a new foundation to make it super simple to organize your code and later manage multiple of them. Remember if this is your first foundation you have to initialize the collie with `collie init/`.
```bash
mkdir cloudfoundation && cd cloudfoundation
collie init
collie foundation new <name of our foundation>
```
then you will go to interactive mode to configure your cloud environment. After choosing the right options click save and exit.

2- **Bootstrapping**

















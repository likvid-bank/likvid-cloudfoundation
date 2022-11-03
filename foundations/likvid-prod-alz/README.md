# likvid-prod-alz

Building a landing zone in Azure can be a daunting task, especially since Microsoft provides various options to pursue, from Azure resource manager (ARM) templates to Terraform modules. If you’d like to see how the different ways compare, check out our [Azure landing zone comparison](https://www.meshcloud.io/2022/09/27/azure-landing-zone-comparison/) blog post. In the end, any approach will implement the Azure landing zone conceptual architecture (also called enterprise scale in other contexts), or part of it:

![image](https://user-images.githubusercontent.com/96071919/199272145-0524367e-5d7f-4f91-9ed2-29e12078c129.png)


That already seems like a lot, doesn’t it? Certainly not something that a solo Platform Engineer or an Enterprise Architect will find easy to do. But that’s fine since Azure already has a ready-to-use Terraform module that will create the baseline of that architecture (image below).

![image](https://user-images.githubusercontent.com/96071919/199272328-25a0e6b0-4f1f-4824-9b77-08776c1e6ed8.png)

There are many reasons to start with [Azure landing zones Terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki):

- Microsoft recommends it for most organizations.
- It is lightweight, and quick to deploy.
- Their repository includes a Wiki with detailed examples to use.
- It paves your way to adopting GitOps from the get-go.
- It prepares your landing zone setup for scale.

The remaining open questions that are not covered by only using this module are:

- How can I store the terraform state of this module?
- How can I restrict access to the terraform state file to specific users?
- As a Platform Engineer or an Enterprise Architect, I have other resources I want to include in my cloud foundation that is not covered by this module, how can I do that?

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
Follow [collie-cli installation guidelines](https://github.com/meshcloud/collie-cli#-installation) to install `collie-cli`. After that, we will check that collie works properly.
```bash
collie -V
```
After installing collie and its required dependencies, login with az cli to the AAD tenant where you will deploy your landing zones.
```bash
az login --tenant <aadTenantPrimaryDomain>
```

### Configuration
1- **New Foundation**

Create a new foundation to make it super simple to organize your code and later manage multiple of them. Remember if this is the first foundation you have to initialize the collie with `collie init`.
```bash
mkdir cloudfoundation && cd cloudfoundation
collie init
collie foundation new <name of your foundation>
```
then you will go to interactive mode to configure your cloud environment. After choosing the right options click save and exit.

2- **Bootstrapping**

The bootstrap kit creates a `Service Principal` with just enough permissions to deploy the resources for the ALZ and other kits which you might add later. Also creating a storage account and defining the backend for terraform is this module's responsibility.
From Collie v0.14.0 and higher, in addition to the mentioned tasks, migration of the terraform state file will be done automatically for you.
Execute the following command to deploy the bootstrap module and download the alz kit from azure's git repository.

```bash
collie kit bundle <a name for your kit bundle>
```
You will be then, prompted to input some values related to deploying the alz kit and bootstrap module.

3- **Rolling out the alz kit**
Now all you need to do is to deploy your landing zones with this command:
```bash
collie foundation deploy <name of your foundation> --platform <platform name> --module base
```
This uses the previously configured inputs to deploy the Azure landing zone Terraform module. It will take roughly 30 minutes to create all the cloud resources. 
### That’s it!

Now you have deployed your landing zones with our bootstrap module and Azure Enterprise Scale module

- You have your Terraform state managed in your new object storage
- Access to that storage is restricted to specific users (those included in the foundation platform engineers group).
- Your foundation has everything defined as code and you can utilize the Landing Zone Construction Kit to update your landing zones.

## Useful information
- You can pass terraform's command inline with collie using `--`: 
```bash
collie foundation deploy my-foundation --platform azure --module -- plan 
```
- Destroy the alz kit and bootstrap kit respectively with these commands:
```bash
collie foundation deploy <name of your foundation> --platform <name of the platform> --module <name of the alz kit> -- destroy
collie foundation deploy <name of your foundation> --bootstrap -- destroy
```
- File Structure

The following commands help you better understand the structure of files created in this Landing zone construction kit:
```bash
tree
collie foundation tree
collie kit tree
```
collie foundation tree output -> <img width="1152" alt="image" src="https://user-images.githubusercontent.com/96071919/199353827-d8d92d4a-3fa7-4a76-99c8-10af7a900dad.png">
collie kit tree output -> <img width="1057" alt="image" src="https://user-images.githubusercontent.com/96071919/199353977-c8d16bca-b165-49ef-9435-06c5f6790e8e.png">


### Note
The `module.hcl`, `Platform.hcl` (which are unique in every foundation), and `terragrunt.hcl` (every kit has one) are terragrunt files used to manage terraform modules and pass the variables and providers for them. You might need to edit one or all of them in order to create your custom kits.

You can find further information about collie's functions and building a landing zone with collie in [collie-cli](https://github.com/meshcloud/collie-cli) and [Landing Zone Construction Kit](https://github.com/meshcloud/landing-zone-construction-kit) repositories.


## What is next
You can customize your `azure landing zone` following these [examples](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples) from Microsoft or add tailor-made kits to your foundation with `collie kit` command:
```bash
collie kit new <kit name>
```
As a result, a module will be added under the kit folder with different Terraform files which you can edit to your needs.
for deploying these kits run:
```bash
collie kit apply
collie foundation deploy <name of your foundation> --platform <name of the platform> --module <name of your kit>
```


















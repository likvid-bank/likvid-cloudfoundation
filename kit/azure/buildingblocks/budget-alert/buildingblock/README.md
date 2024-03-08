# Budget-Alert-building-block
This building block sets up a budget at your subscription scope. In additition, an associated Action group will be configured as well.
The "Contact_emails" variable should contain the email of the people who ought to receive the alert email. The action group on top of that can add more functionalities like triggering a function app or a webhook.


![image](https://github.com/meshcloud/building-blocks/assets/96071919/a68461a8-f4fc-42f9-9496-50926b858b8d)


## How to use this Building Block in meshStack 
**Note**: If you are ***not*** using Collie-hub to generate the backend and provider information, please uncomment the "provider_alternate.tf" lines.
1. Go to your meshStack admin area and click on "Building Blocks" from the left pane
2. Click on "Create Building Block"
3. Fill out the general information and click next
4. Select "Azure" as your supported platform 
5. Select "Terraform" in Implementation Type and put in the Terraform version
6. Copy the repository HTTPS address to the "Git Repository URL" field (if its a private repo, add your SSH key) click next
7. For the input do the following
    - Click on "generate auth inputs" button and fill the inputs: "ARM_CLIENT_SECRET", "ARM_CLIENT_ID", "ARM_SUBSCRIPTION_ID", "ARM_TENANT_ID" as Environmental Variable
    - add the add the "subscription_id" as "Platform Tenant ID"
    - add the rest of the variables as static, platform operator or user input
8. On the next page, add the outputs from outputs.tf file and click on Create Building Block
9. Now users can add this building block to their tenants

## Backend configuration
Here you can find an example of how to create a backend.tf file on this [Wiki Page](https://github.com/meshcloud/building-blocks/wiki/%5BUser-Guide%5D-Setting-up-the-Backend-for-terraform-state#how-to-configure-backendtf-file-for-these-providers)

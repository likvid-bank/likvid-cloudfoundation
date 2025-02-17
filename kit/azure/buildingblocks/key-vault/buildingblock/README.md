# Terraform Module: Azure Key Vault

This Terraform module provisions an Azure Key Vault along with necessary role assignments.

## Features
- Creates an Azure Key Vault with soft delete and purge protection enabled.
- Assigns the "Key Vault Administrator" role to a specified Azure AD group.
- Outputs essential details like Key Vault ID, name, and resource group.

## Requirements
- Terraform `>= 1.0`
- AzureRM Provider `>= 4.18.0`

## Providers

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## Inputs

| Name                          | Type   | Description                                      | Required |
|--------------------------------|--------|--------------------------------------------------|----------|
| `key_vault_name`              | string | The name of the Key Vault.                      | Yes      |
| `key_vault_resource_group_name` | string | The name of the resource group for the Key Vault. | Yes      |
| `location`                    | string | The Azure region where the Key Vault is created. | Yes      |

## Outputs

| Name                        | Description                                    |
|-----------------------------|------------------------------------------------|
| `key_vault_id`             | The ID of the created Key Vault.              |
| `key_vault_name`           | The name of the created Key Vault.            |
| `key_vault_resource_group` | The resource group containing the Key Vault.  |

## Usage Example

```hcl
module "key_vault" {
  source                        = "./modules/key_vault"
  key_vault_name                = "my-keyvault"
  key_vault_resource_group_name = "my-resource-group"
  location                      = "West Europe"
}

output "vault_id" {
  value = module.key_vault.key_vault_id
}
```

## Notes
- Make sure the Azure AD group exists before assigning the role.
- Ensure that your Terraform identity has the necessary permissions to create and manage Key Vaults.

## License
MIT


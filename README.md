# Likvid Bank Cloud Foundation

> This is an example implementation of a cloud foundation built using
> [Landing Zone Construction Kit](https://landingzone.meshcloud.io)
> and [Microsoft azure landing zone terraform module](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale)

This repository consists of 2 different foundations, `Likvid-prod/` and `Likvid-prod-alz/`. 
Likvid-prod-alz uses azure landing zone terraform module to accelerate deployment of platform resources based on the [Azure landing zones conceptual architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone#azure-landing-zone-conceptual-architecture). 

This repository also contains configuration for `collie` to work with your clouds with a structured workflow.

- `foundations/` defines a set of cloud platforms and their configuration
- `kit/` stores IaC modules to assemble landing zones on your foundations' cloud platforms
- `compliance/` stores compliance controls that your kit modules implement

Collie stores data in the form of "literate" config files - markdown config files with YAML frontmatter.
This approach allows `collie` to generate documentation for your cloud foundations later

## Next steps

How to create a landing zone using collie (check [likvid-prod](https://github.com/likvid-bank/likvid-cloudfoundation/tree/main/foundations/likvid-prod))

How to create a landing zone with collie based on azure landing zone terraform module (check [likvid-prod-alz](https://github.com/likvid-bank/likvid-cloudfoundation/tree/main/foundations/likvid-prod-alz))


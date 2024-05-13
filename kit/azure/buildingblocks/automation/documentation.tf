output "documentation_md" {
  value = <<EOF
# Building Block - Automation Infrastructure

The Automation Infrastructure Building Block configures the basic infrastructure for deploying a Building Block in a subscription. For this, we use a
Service Principal to manage the resources in the subscription. This Service Principal is also used by meshStack.

graph LR
    A[${azuread_application.buildingblock.display_name}]
    C[meshStack]
    D[Azure Subscription]
    E[Building Block]
    A -->|Configures| E
    E -->|Deployed in| D
    C -->|Uses| A

EOF
}

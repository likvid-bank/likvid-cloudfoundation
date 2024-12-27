terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.management, aws.meshcloud, aws.automation]
      version               = "5.65.0"
    }
  }
}

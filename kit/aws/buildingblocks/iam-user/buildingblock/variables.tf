# used in injected config.tf file for configuring the aws provider
# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "user_name" {
  description = "Name of the IAM user"
  default     = "example_user"
}

variable "user_path" {
  description = "Path in which to create the user"
  default     = "/system/"
}

variable "account_id" {
  description = "The ID of the AWS Account in which to create the user"
}


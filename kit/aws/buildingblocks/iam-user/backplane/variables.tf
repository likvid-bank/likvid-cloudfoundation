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


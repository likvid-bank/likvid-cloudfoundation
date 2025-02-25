variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

module "buildingblock" {
  source = "git::https://github.com/meshcloud/collie-hub.git//kit/aws/buildingblocks/s3_bucket/buildingblock?ref=91b6c3c0adb55228d523592a7570be781757cf2e"

  region      = var.region
  bucket_name = var.bucket_name
}

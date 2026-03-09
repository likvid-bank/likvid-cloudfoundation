terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.83"
    }
  }
}

variable "stackit_project_id" {
  description = "STACKIT project UUID"
  type        = string
}

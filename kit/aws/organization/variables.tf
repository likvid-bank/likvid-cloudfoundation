variable "parent_ou_name" {
  type        = string
  nullable    = false
  description = <<EOF
    Create a OU of the specified name and treat it as the root of all resources managed as part of this kit.
    This is good for separation, in particular if you don't have exclusive control over the AWS organization because
    it is supporting non-cloudfoundation workloads as well.
  EOF
}

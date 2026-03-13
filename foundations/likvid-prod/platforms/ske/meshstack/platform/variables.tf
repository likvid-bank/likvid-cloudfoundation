variable "meshstack" {
  type = object({
    owning_workspace_identifier = string
    location_identifier         = string
  })
}

variable "kube_host" {
  description = "Kubernetes API server URL"
  type        = string
}

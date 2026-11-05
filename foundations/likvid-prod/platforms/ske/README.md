# STACKIT Kubernetes Engine

[`platform`](platform) orders the hub's STACKIT Kubernetes Platform reference architecture in the
workspace `devops-platform`. It owns the cluster, Git, DNS, ingress, the meshPlatform
`ske-namespace` with its landing zones and the starterkit definitions application teams order.


## Access Kubernetes cluster

To access the cluster, use the `stackit` CLI tool. Run:

```bash
stackit auth login

stackit config set --project-id 47787660-94b9-4fb6-8bf7-53a90c41b26a
stackit ske kubeconfig create starterkit --login
```

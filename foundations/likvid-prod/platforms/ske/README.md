# STACKIT Kubernetes Engine

[`platform`](platform) orders the hub's STACKIT Kubernetes Platform reference architecture in the
workspace `devops-platform`. It owns the cluster, Git, DNS, ingress, the meshPlatform
`ske-namespace` with its landing zones and the starterkit definitions application teams order.

[`platform/hub.hcl`](platform/hub.hcl) pins the hub ref for the platform and for its nightly smoke
test [`platform/e2e`](platform/e2e), which orders the published **SKE Starterkit** in
`devops-platform` and checks that the app serves over TLS.


## Access Kubernetes cluster

To access the cluster, use the `stackit` CLI tool. Run:

```bash
stackit auth login

stackit config set --project-id 47787660-94b9-4fb6-8bf7-53a90c41b26a
stackit ske kubeconfig create starterkit --login
```

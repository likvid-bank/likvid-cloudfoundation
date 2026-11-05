# STACKIT Kubernetes Engine

[`platform`](platform) orders the hub's STACKIT Kubernetes Platform reference architecture in the
workspace `devops-platform`. It owns the cluster, Git, DNS, ingress, the meshPlatform
`ske-namespace` with its landing zones and the starterkit definitions application teams order.

`starterkit` keeps the Model Serving token that building blocks on the old starterkit versions put
into their namespaces; it goes once they are all upgraded.


## Access Kubernetes cluster

To access the cluster, use the `stackit` CLI tool. Run:

```bash
stackit auth login

stackit config set --project-id 47787660-94b9-4fb6-8bf7-53a90c41b26a
stackit ske kubeconfig create starterkit --login
```

## Container Images of the old starterkit versions (one-time manual setup)

Starterkit templates build on base images pulled from our Harbor project, not from Docker Hub.
Mirroring those base images is **manual, one-time setup** — not managed by Terragrunt.

Harbor could do this itself via a proxy cache project or a replication rule, but the Harbor project
is shared across all STACKIT customers and we only hold robot credentials, no admin rights. Ask
STACKIT support if you want this automated.

To mirror an image:

```bash
source setup-env.sh # from the repo root, exports the Harbor push robot credentials
./mirror-image.sh docker.io/library/python:3.12.9-slim-bookworm
```

Already mirrored:

| Upstream                                       | Used by                          |
|------------------------------------------------|----------------------------------|
| `docker.io/library/python:3.12.9-slim-bookworm` | `ai-summarizer` starterkit template |

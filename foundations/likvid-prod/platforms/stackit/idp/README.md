# STACKIT IDP

This contains all resources required to set up STACKIT IDP.

## State Backend

Existing GCS bucket `meshcloud-tf-states`, prefix `path/to/<module>`. Configured in [idp.hcl](idp.hcl).

## Apply

Requires a Vault port-forward to `localhost:8200`. Load credentials with `source setup.sh`, then apply:

```bash
terragrunt run --all apply
```

Terragrunt resolves the dependency order automatically. To target a single module: `cd <module> && terragrunt apply`, e.g. `cd infra && terragrunt apply`. Use the graph in section [Module Dependencies](#module-dependencies) to know which modules need to be applied first.

## Module Dependencies

Helps in knowing order of execution (arrow = depends on).

![dependency graph](dep.png)

Generate the graph with: `terragrunt dag graph  | dot -Tpng > dep.png`

## Access SKE cluster

To access the SKE cluster, use the `stackit` CLI tool. Run:

```bash
stackit auth login

stackit config set --project-id 47787660-94b9-4fb6-8bf7-53a90c41b26a
stackit ske kubeconfig create starterkit --login
```

#!/usr/bin/env bash
# This script loads credentials from Hashicorp Vault into (exported) env vars from the secret specified below:
vaultSecret=concourse/meshstack-dev/likvid-cloudfoundation

# Needs:
# * Hashicorp Vault CLI (command vault)
# * kubectl with access to the meshcloud internal infra kubernetes cluster hosting the Vault.

# Source this script into your local shell:
# > source setup-env.sh
# DO NOT execute this script (this script is intentionally marked non-executable).

set -a
# shellcheck disable=SC1090
source <(
  set -euo pipefail

  # Find the correct kubectl context created by gcloud
  kubeContext=$(kubectl config get-contexts -o name | grep '^gke_meshstack-infra.*_meshstack-infra$' | head -n1)
  if [[ -z "$kubeContext" ]]; then
    echo "Failed to find kubectl context with prefix gke_meshstack-infra, try connecting by running: " >&2
    echo "gcloud container clusters get-credentials meshstack-infra --region europe-west3 --project meshstack-infra" >&2
    exit 1
  fi

  # Set up kubectl port-forward to vault with random local port
  kubectlOutput=$(mktemp)
  kubectl port-forward --context "$kubeContext" -n vault-new svc/vault :8200 >"$kubectlOutput" 2>&1 &
  kubectlPid=$!
  # shellcheck disable=SC2064
  trap "kill $kubectlPid 2>/dev/null || true; rm -f '$kubectlOutput'" EXIT

  # Wait for port-forward to establish and extract the local port
  for i in $(seq 10 -1 0); do
    localVaultPort=$(sed -n 's/.*Forwarding from 127.0.0.1:\([0-9]*\).*/\1/p' "$kubectlOutput" 2>/dev/null || true)
    if [[ -n "$localVaultPort" ]]; then
      export VAULT_ADDR=http://localhost:$localVaultPort
      echo "Opened port forward to meshstack-infra vault at $VAULT_ADDR (attempts left: $i)" >&2
      break
    elif ((i == 0)); then
      echo "$i: Failed to establish port-forward:" >&2
      cat "$kubectlOutput" >&2
      exit 1
    fi
    sleep 0.5
  done

  # Check if vault is already logged in, if not login with OIDC
  if ! vault token lookup &>/dev/null; then
    vault login -method=oidc >&2
  fi

  echo "Exporting the following SENSITIVE environment variables: " >&2
  vault kv get -format=json "$vaultSecret" |
    jq -r '.data.data | to_entries[] | "\(.key)='\''\(.value)'\''"' |
    tee >(tr '\n' '\0' | sed "s/='[^']*'//g" | tr '\0' '\n' >/dev/stderr)
)
set +a

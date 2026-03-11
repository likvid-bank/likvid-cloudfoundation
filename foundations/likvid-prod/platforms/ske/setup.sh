#!/usr/bin/env bash
# Loads credentials from Vault into env vars.
# Requires a Vault port-forward to localhost:8200.
set -a
source <(vault kv get \
  -format=json \
  -address="http://localhost:8200" \
  concourse/meshstack-dev/likvid-cloudfoundation \
  | jq -r '.data.data | to_entries[] | "\(.key)='\''\(.value)'\''"')
set +a

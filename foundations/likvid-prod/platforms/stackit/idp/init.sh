#! /bin/bash

set -o allexport;
source <(vault kv get -address="http://localhost:8200" -format=json concourse/meshstack-dev/likvid-cloudfoundation | jq -r '.data.data | to_entries[] | "\(.key)='\''\(.value)'\''" ');
set +o allexport

# re-export environment variables for terraform, assuming you have sourced secrets from vaul
export TF_VAR_gitea_token="$STACKIT_GITEA_TOKEN"
export MESHSTACK_ENDPOINT="https://federation.demo.meshcloud.io"
export MESHSTACK_API_KEY="6169f530-0eaa-4f7f-91b7-c4fd4aaf2a74"
export MESHSTACK_API_SECRET="$MESHSTACK_API_KEY_CLOUDFOUNDATION"
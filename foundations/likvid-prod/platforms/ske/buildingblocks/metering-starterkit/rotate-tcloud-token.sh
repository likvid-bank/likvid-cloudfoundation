#!/usr/bin/env bash
# Replaces the T Cloud Financial Dashboard token that the T Cloud metering CronJob reads. The
# dashboard accepts only its own Grafana service account tokens, and T Cloud lets them live at most
# 90 days, so run this before the current token expires.
set -euo pipefail

context=${KUBE_CONTEXT:-starterkit}
namespace=devops-platform-metering
secret=mesh-metering-tcloud-api-token
api=https://api-enterprise-dashboard.otc-service.com/v2/daily/consumption/

cat <<'EOF'
Create a new Financial Dashboard token:

  1. Open https://financial-dashboard.otc-service.com and sign in with "MyWorkplace"
     (Telekom Business Login, the meshcloud T Cloud account from Bitwarden).
  2. Go to Administration > Users and access > Service accounts.
  3. Open the service account the metering uses (role Admin), or create one, e.g. meshstack-metering.
  4. Click "Add service account token", set the expiry to at most 90 days, and copy the token
     (it starts with glsa_). Note the expiry date.
  5. Delete the old token of that service account once the new one works.

EOF

read -r -s -p "New token (hidden): " token
echo
token=$(printf '%s' "$token" | tr -d '[:space:]')
[[ $token == glsa_* ]] || { echo "This is no Grafana service account token (glsa_…)." >&2; exit 1; }

status=$(curl -sS -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" "$api?date=$(date -d yesterday +%F)")
[ "$status" = 200 ] || { echo "The Consumption API rejected the token with HTTP $status." >&2; exit 1; }
echo "The Consumption API accepts the token."

if ! kubectl --context "$context" get namespace "$namespace" >/dev/null 2>&1; then
  cat >&2 <<EOF
No access to namespace $namespace with kubectl context $context. Fetch it with:
  stackit config set --project-id 47787660-94b9-4fb6-8bf7-53a90c41b26a && stackit ske kubeconfig create starterkit --login -y
EOF
  exit 1
fi

kubectl --context "$context" -n "$namespace" create secret generic "$secret" \
  --from-literal=TCLOUD_API_TOKEN="$token" --dry-run=client -o yaml |
  kubectl --context "$context" -n "$namespace" apply -f -

echo
echo "Check it with a run right away:"
echo "  kubectl --context $context -n $namespace create job --from=cronjob/mesh-metering-tcloud mesh-metering-tcloud-manual"
echo "  kubectl --context $context -n $namespace logs -f job/mesh-metering-tcloud-manual"

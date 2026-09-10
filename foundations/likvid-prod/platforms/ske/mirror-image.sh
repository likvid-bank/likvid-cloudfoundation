#!/usr/bin/env bash
# One-time manual setup: mirror an upstream container image into the SKE Harbor project.
#
# We hold only robot credentials for STACKIT's shared Harbor, not the admin rights needed to set up
# a proxy cache or a replication rule. Base images that starterkit templates build on are therefore
# mirrored by hand, once per image, instead of by a Terragrunt module.
#
#   source ../../../../setup-env.sh   # exports the Harbor push robot credentials from Vault
#   ./mirror-image.sh docker.io/library/python:3.12.9-slim-bookworm

set -euo pipefail

registry="registry.onstackit.cloud"
project="stackit_kubernetes_platform"

if [ $# -eq 0 ]; then
  echo "usage: $0 <fully-qualified-image>..." >&2
  echo "example: $0 docker.io/library/python:3.12.9-slim-bookworm" >&2
  exit 1
fi

: "${STACKIT_HARBOR_PUSH_ROBOT_USER:?not set, source setup-env.sh first}"
: "${STACKIT_HARBOR_PUSH_ROBOT_PASSWORD:?not set, source setup-env.sh first}"

for image in "$@"; do
  # Mirror under a flat name so upstream namespaces (library/, bitnami/) don't leak into the path.
  target="$registry/$project/${image##*/}"

  echo "mirroring $image -> $target"

  # --override-* pins the copy to the architecture SKE nodes run, so mirroring from an arm64 laptop
  # still yields a usable image without dragging along the six other arches of a multi-arch tag.
  #
  # --insecure-policy skips signature verification. The nix skopeo ships no default policy.json and
  # we don't verify upstream signatures anyway.
  skopeo --insecure-policy copy --override-os linux --override-arch amd64 \
    --dest-creds "$STACKIT_HARBOR_PUSH_ROBOT_USER:$STACKIT_HARBOR_PUSH_ROBOT_PASSWORD" \
    "docker://$image" "docker://$target"
done

#!/usr/bin/env bash
set -euo pipefail

RUN_CMD="$1"
BIN_REF="$2"
IMAGE="$3"

cat <<EOF > github.env
GITHUB_SHA=$GITHUB_SHA
GITHUB_REF=$GITHUB_REF
GITHUB_REF_NAME=$GITHUB_REF_NAME
GITHUB_RUN_ID=$GITHUB_RUN_ID
GITHUB_REPOSITORY=$GITHUB_REPOSITORY
GITHUB_EVENT_NAME=$GITHUB_EVENT_NAME
GITHUB_ACTOR=$GITHUB_ACTOR
GITHUB_TOKEN=$GITHUB_TOKEN
CIBUILD_CANCEL_TOKEN=$CIBUILD_CANCEL_TOKEN
CIBUILD_TARGET_REGISTRY_PASS=$CIBUILD_TARGET_REGISTRY_PASS
CIBUILDER_BIN_REF=$BIN_REF
CIBUILD_RUN_CMD=$RUN_CMD
DOCKER_HOST=tcp://docker:2375
DOCKER_TLS_VERIFY=
DOCKER_TLS_CERTDIR=
EOF

docker network create cibuilder-net

docker run --privileged --rm \
  --env-file github.env \
  --network cibuilder-net \
  --network-alias docker \
  docker:dind

docker run --privileged --rm \
  --env-file github.env \
  -v "$PWD:/workspace" \
  -w /workspace \
  --network cibuilder-net \
  "$IMAGE"

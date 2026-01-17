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

docker network inspect cibuilder-net

docker run --privileged --rm -d \
  --env-file github.env \
  --network cibuilder-net \
  --network-alias docker \
  --name cibuilder-dind \
  docker:dind
  
  # \
  # dockerd \
  #   --host=tcp://0.0.0.0:2375 \
  #   --host=unix:///var/run/docker.sock \
  #   --insecure-registry=localregistry.example.com:5000 \
  #   --default-address-pool base=10.10.0.0/16,size=24

sleep 10
docker logs cibuilder-dind

docker run --privileged --rm \
  --env-file github.env \
  -v "$PWD:/workspace" \
  -w /workspace \
  --network cibuilder-net \
  --name cibuilder \
  "$IMAGE"

#!/usr/bin/env bash
export NOMAD_ADDR="http://10.8.0.1:4646"
export DOCKER_REPO="10.8.0.5:5000"

JOB_NAME=$1
VER=$2

TAG="${DOCKER_REPO}/${JOB_NAME}:${VER}"

cd docker/${JOB_NAME}
docker build -t "${TAG}" . && docker push "${TAG}"

RESULT=$?

cd ../..
if [ $RESULT -eq 0 ]; then
  nomad job run "services/${JOB_NAME}.nomad"
fi


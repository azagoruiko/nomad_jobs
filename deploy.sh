#!/usr/bin/env bash
export NOMAD_ADDR="http://10.8.0.1:4646"
export DOCKER_REPO="10.8.0.5:5000"

JOB_NAME=$1
VER=$2

TAG="${DOCKER_REPO}/{JOB_NAME}:${VER}"

docker build -t "${TAG}" . && /
docker push "${TAG}" && /
nomad job run "${JOB_NAME}.nomad"
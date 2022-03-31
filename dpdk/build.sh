#!/bin/bash

# Point to your local registry
#REGISTRY='cnfde2.ptp.lab.eng.bos.redhat.com:5000'
REGISTRY='quay.io/dosman'
#PULL_SECRET="${PWD}/pull-secret.txt"
PULL_SECRET="${PWD}/config.json"
DPDK_IMAGE='dpdk'

podman build -f Dockerfile --no-cache . \
  --authfile=${PULL_SECRET} \
  -t ${REGISTRY}/${DPDK_IMAGE}

podman push --authfile=${PULL_SECRET} --tls-verify=false ${REGISTRY}/${DPDK_IMAGE}

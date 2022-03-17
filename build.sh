#!/bin/bash

export ICE_DRIVER_VER='1.6.7'
export BASE_IMAGE='registry.access.redhat.com/ubi8-minimal:latest'
export DRIVER_TOOLKIT_IMAGE='quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:c11cee307c9f0f57f452de4ef82208d433c732764b04194fc8fa8cec8a9d7a07'
export KERNEL_VER='4.18.0-305.40.1.rt7.112.el8_4.x86_64'
export PULL_SECRET="${PWD}/pull-secret.txt"
export LOCAL_REGISTRY='registry.ran-vcl01.ptp.lab.eng.bos.redhat.com:5000'
export DRIVER_IMAGE='oot-ice'
export TAG=${KERNEL_VER}

podman build -f Dockerfile --no-cache . \
 --build-arg IMAGE=registry.access.redhat.com/ubi8-minimal:latest \
 --build-arg BUILD_IMAGE=${DRIVER_TOOLKIT_IMAGE} \
 --build-arg DRIVER_VER=${ICE_DRIVER_VER} \
 --build-arg KERNEL_VERSION=${KERNEL_VER}\
 --authfile=${PULL_SECRET} \
  -t ${LOCAL_REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}


podman push --authfile=${PULL_SECRET} --tls-verify=false ${LOCAL_REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}

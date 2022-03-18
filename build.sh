#!/bin/bash

set -eu
ICE_DRIVER_VER=$1; shift
OCP_VER=$1; shift

# Point to your local registry
LOCAL_REGISTRY='cnfde2.ptp.lab.eng.bos.redhat.com:5000'

BASE_IMAGE='registry.access.redhat.com/ubi8-minimal:latest'
DRIVER_IMAGE='oot-ice'
PULL_SECRET="${PWD}/pull-secret.txt"

DTK_IMAGE=$(oc adm -a ${PULL_SECRET} release info --image-for=driver-toolkit quay.io/openshift-release-dev/ocp-release:${OCP_VER}-x86_64)

STD_KERNEL_VER=$(podman run --authfile ${PULL_SECRET} --rm ${DTK_IMAGE} rpm -qa | grep 'kernel-core-' | sed 's#kernel-core-##')
RT_KERNEL_VER=$(podman run --authfile ${PULL_SECRET} --rm ${DTK_IMAGE} rpm -qa | grep 'kernel-rt-core-' | sed 's#kernel-rt-core-##')

echo "DTKI for OCP-${OCP_VER} : ${DTK_IMAGE}"

for KERNEL_VER in `echo "${STD_KERNEL_VER} ${RT_KERNEL_VER}"`; do
  echo "Building for ${KERNEL_VER}"
  TAG=${KERNEL_VER}

  podman build -f Dockerfile --no-cache . \
   --build-arg IMAGE=${BASE_IMAGE} \
   --build-arg BUILD_IMAGE=${DTK_IMAGE} \
   --build-arg DRIVER_VER=${ICE_DRIVER_VER} \
   --build-arg KERNEL_VERSION=${KERNEL_VER}\
   --authfile=${PULL_SECRET} \
    -t ${LOCAL_REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}

  podman push --authfile=${PULL_SECRET} --tls-verify=false ${LOCAL_REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}
done

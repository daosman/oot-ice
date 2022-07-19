#!/bin/bash

set -eu
ICE_DRIVER_VER=$1; shift
OCP_VER=$1; shift

# Point to your local registry
REGISTRY='cnfde2.ptp.lab.eng.bos.redhat.com:5000'
MIRROR='cnfde2.ptp.lab.eng.bos.redhat.com:6666'
BASE_IMAGE='registry.access.redhat.com/ubi8-minimal:latest'
DRIVER_IMAGE='oot-ice'

GET_DEVEL_RPM="no"
BUILD_RT="no"
KERNEL_VER=""

MACHINE_OS=$(oc adm release info --image-for=machine-os-content quay.io/openshift-release-dev/ocp-release:${OCP_VER}-x86_64)
DTK_IMAGE=$(oc adm release info --image-for=driver-toolkit quay.io/openshift-release-dev/ocp-release:${OCP_VER}-x86_64)
if [ ! -z ${KERNEL_VER} ]; then
  GET_DEVEL_RPM="yes"
elif [ ${BUILD_RT} == "yes" ]; then
  KERNEL_VER=$(oc image info -o json ${MACHINE_OS}  | jq -r ".config.config.Labels[\"com.coreos.rpm.kernel-rt-core\"]")
else
  KERNEL_VER=$(oc image info -o json ${MACHINE_OS}  | jq -r ".config.config.Labels[\"com.coreos.rpm.kernel\"]")
fi


TAG=${KERNEL_VER}

echo "DTKI for OCP-${OCP_VER} : ${DTK_IMAGE}"
echo "Building for ${KERNEL_VER}"

podman build -f Dockerfile --no-cache . \
  --build-arg IMAGE=${BASE_IMAGE} \
  --build-arg BUILD_IMAGE=${DTK_IMAGE} \
  --build-arg DRIVER_VER=${ICE_DRIVER_VER} \
  --build-arg KERNEL_VERSION=${KERNEL_VER} \
  --build-arg MIRROR=${MIRROR} \
  --build-arg GET_DEVEL_RPM=${GET_DEVEL_RPM} \
  -t ${REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}

podman push --tls-verify=false ${REGISTRY}/intel/${DRIVER_IMAGE}:${TAG}

#!/bin/bash

set -eu

# Change it to your desired ice and OCP versions
ICE_DRIVER_VER='1.14.8'
OCP_VERSION='4.16.0-0.nightly-2024-04-30-053518'

# Point to your registry
REGISTRY='quay.io/dosman'

OCP_RELEASE='registry.ci.openshift.org/ocp/release'

BASE_IMAGE=$(oc adm release info --registry-config=pull-secret.txt "${OCP_RELEASE}:${OCP_VERSION}" --image-for=rhel-coreos)
DTK_IMAGE=$(oc adm release info  --registry-config=pull-secret.txt "${OCP_RELEASE}:${OCP_VERSION}" --image-for=driver-toolkit)

KERNEL_VER=$(podman run --authfile=pull-secret.txt --rm ${DTK_IMAGE} rpm -qa | grep 'kernel-core-' | sed 's#kernel-core-##')
PATCHED_OS_IMAGE='coreos-dell-oot-ice'
TAG=${KERNEL_VER}

echo "OCP_VERSION=${OCP_VERSION}"
echo "OCP_RELEASE=${OCP_RELEASE}"
echo "REGISTRY=${REGISTRY}"
echo "BASE_IMAGE=${BASE_IMAGE}"
echo "DTK_IMAGE=${DTK_IMAGE}"
echo "KERNEL_VER=${KERNEL_VER}"
echo "PATCHED_OS_IMAGE=${PATCHED_OS_IMAGE}"

podman build --authfile=pull-secret.txt -f Dockerfile --no-cache . \
  --build-arg IMAGE=${BASE_IMAGE} \
  --build-arg BUILD_IMAGE=${DTK_IMAGE} \
  --build-arg DRIVER_VER=${ICE_DRIVER_VER} \
  --build-arg KERNEL_VERSION=${KERNEL_VER} \
  -t ${REGISTRY}/${PATCHED_OS_IMAGE}:${TAG}

podman push --tls-verify=false ${REGISTRY}/${PATCHED_OS_IMAGE}:${TAG}

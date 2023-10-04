#!/bin/bash

set -eu
ICE_DRIVER_VER=$1; shift

# Point to your local registry
REGISTRY='registry.cnfde20.ptp.lab.eng.bos.redhat.com:5000/ran-test'
#REGISTRY='quay.io/dosman'

OCP_VERSION='4.14.0-0.nightly-2023-10-02-162419'
OCP_RELEASE='registry.ci.openshift.org/ocp/release'
#OCP_VERSION='4.14.0-rc.1-x86_64'
#OCP_RELEASE='quay.io/openshift-release-dev/ocp-release'

BASE_IMAGE=$(oc adm release info "${OCP_RELEASE}:${OCP_VERSION}" --image-for=rhel-coreos)
DTK_IMAGE=$(oc adm release info  "${OCP_RELEASE}:${OCP_VERSION}" --image-for=driver-toolkit)

KERNEL_VER=$(podman run --rm ${DTK_IMAGE} rpm -qa | grep 'kernel-core-' | sed 's#kernel-core-##')
PATCHED_OS_IMAGE='coreos-intel-oot'
TAG=${KERNEL_VER}

echo "OCP_VERSION=${OCP_VERSION}"
echo "OCP_RELEASE=${OCP_RELEASE}"
echo "REGISTRY=${REGISTRY}"
echo "BASE_IMAGE=${BASE_IMAGE}"
echo "DTK_IMAGE=${DTK_IMAGE}"
echo "KERNEL_VER=${KERNEL_VER}"
echo "PATCHED_OS_IMAGE=${PATCHED_OS_IMAGE}"

podman build -f Dockerfile --no-cache . \
  --build-arg IMAGE=${BASE_IMAGE} \
  --build-arg BUILD_IMAGE=${DTK_IMAGE} \
  --build-arg DRIVER_VER=${ICE_DRIVER_VER} \
  --build-arg KERNEL_VERSION=${KERNEL_VER} \
  -t ${REGISTRY}/${PATCHED_OS_IMAGE}:${TAG}

podman push --tls-verify=false ${REGISTRY}/${PATCHED_OS_IMAGE}:${TAG}

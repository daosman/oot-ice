#!/bin/bash

oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > ${CLUSTER}.pullsecret 
oc registry login   --registry="${REGISTRY_FQDN}:${REGISTRY_PORT}" -auth-basic="${REGISTRY_USER}:${REGISTRY_PASSWORD}" > ${CLUSTER}.pullsecret
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=${CLUSTER}.pullsecret

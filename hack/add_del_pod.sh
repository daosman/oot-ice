#!/bin/bash

KUBECONFIG='/home/dosman/bugs/sriov/kubeconfig.cnfocto2'

exitOnError () {
  local rc="$1"

  if [[ $rc -ne 0 ]]; then
    echo "ERROR: $tasksetOutput"
    exit $rc
  fi
}

iteration=1
while (true); do
  echo "Add pod: $iteration"
  oc apply -f pods/pod.yml
  exitOnError $?
  oc apply -f pods/pod1.yml
  exitOnError $?
  
  echo "Wait for pod: $iteration"
  oc wait --for=condition=Ready pod dpdk-testpmd --timeout=300s
  exitOnError $?
  oc wait --for=condition=Ready pod dpdk-testpmd-1 --timeout=300s
  exitOnError $?

  echo "Sleep"
  sleep 30

  echo "Delete pod: $iteration"
  oc delete -f pods/pod.yml
  exitOnError $?
  oc delete -f pods/pod1.yml
  exitOnError $?
  ((iteration++))
done

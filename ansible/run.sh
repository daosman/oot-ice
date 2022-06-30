#!/bin/bash

exitOnError () {
  local rc="$1"

  if [[ $rc -ne 0 ]]; then
    echo "ERROR: $tasksetOutput"
    exit $rc
  fi
}

iteration=1
rm -rf run.log
while (true); do
  echo "Reboot SNO: $iteration"
  ansible-playbook  -i inventory.yml reboot.yml &>> run.log
  exitOnError $?

  sleep 600

  ((iteration++))
done

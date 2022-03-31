#!/bin/bash


#dpdk-testpmd -l 2,3 -n 8 --proc-type auto --file-prefix pg -a ${PCIDEVICE_OPENSHIFT_IO_VFIO1} -a ${PCIDEVICE_OPENSHIFT_IO_VFIO2} --main-lcore 2 -- --forward-mode=mac --nb-cores 1 --nb-ports 2 --i --rxq 1 --txq 1 --rxd 2048 --txd 2048 --auto-start

TESTPMD_CMD="dpdk-testpmd \
    -l 2,3 \
    -n 8 \
    --proc-type auto \
    --file-prefix pg \
    -a ${PCIDEVICE_OPENSHIFT_IO_VFIO1} \
    -a ${PCIDEVICE_OPENSHIFT_IO_VFIO2} \
    --main-lcore 2
    -- \
    --forward-mode=mac \
    --nb-cores 1\
    --nb-ports 2 \
    --auto-start \
    --rxq 1 \
    --txq 1 \
    --rxd 2048 \
    --txd 2048"

TESTPMD_CMD=$(echo "${TESTPMD_CMD}" | sed -e "s/\s\+/ /g")

echo "################# TESTPMD #################"
echo -e "Command: ${TESTPMD_CMD}\n"

# start testpmd
tmux new-session -s testpmd -d "${TESTPMD_CMD}; touch /tmp/testpmd-stopped; sleep infinity"

function sigtermhandler() {
    echo "Caught SIGTERM"
    local PID=$(pgrep -f "coreutils.*sleep")
    if [ -n "${PID}" ]; then
        echo "Killing sleep with PID=${PID}"
        kill ${PID}
    else
        echo "Could not find PID for sleep"
    fi
}

trap sigtermhandler TERM

# block, waiting for a signal telling me to stop.  backgrounding and
# using wait allows for signal handling to occur
sleep infinity &
wait $!

# kill testpmd
pkill testpmd

# spin waiting for testpmd to exit
while [ ! -e "/tmp/testpmd-stopped" ]; do
    true
done
rm /tmp/testpmd-stopped

# capture the output from testpmd
echo -e "\nOutput from testpmd:\n"
tmux capture-pane -S - -E - -p -t testpmd

echo -e "###########################################\n"

# kill the sleep that is keeping tmux running
pkill -f sleep


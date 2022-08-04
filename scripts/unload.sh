#!/bin/bash
set -eu

# unload the out-of-tree driver
rmmod irdma || true
rmmod ice

# load the in-tree driver
modprobe ice
modprobe irdma

rm -rf /var/lib/firmware/intel/ice/ddp || true
echo "Unloaded out-of-tree and reloaded in-tree ICE driver"
lsmod | grep ice || true


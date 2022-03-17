#!/bin/bash
set -eu

# unload in-tree driver
rmmod ice || true

# load out-of-tree driver
insmod /ice-driver/ice.ko

echo "Loaded out-of-tree ICE"
lsmod | grep ice || true



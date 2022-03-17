#!/bin/bash
set -eu

# unload the out-of-tree driver
rmmod ice

# load the in-tree driver
modprobe ice

echo "Unloaded out-of-tree and reloaded in-tree ICE driver"
lsmod | grep ice || true


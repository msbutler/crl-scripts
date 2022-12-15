#!/bin/bash
set -e

# This script runs the ycsb f workload on a VM, given the trimmed pebble binary
# file name name (assumed suffix is .o) and number of workers. For example:
# "./pebble.sh writamp 96" will use the writamp.o binary to run the ycsb
# workload with 96 workers.

binary=$1
workers=$2
name=$CLUSTER-$binary-$workers

# Create a good roachprod node
roachprod create $name --nodes=1 --gce-machine-type=n2-standard-16 --local-ssd=false --gce-pd-volume-size=2000

# Push the  _linux_  binaries to roachprod (build from gce worker)
roachprod put $name $binary.o

# Run the workload until lsm is 300 GB
roachprod run $name -- "tmux new -d -s ycsb \"./$binary.o bench ycsb /mnt/data1 --workload F --initial-keys 100000 -c $workers --max-size=300000 -d 0m --wait-compactions > output.txt\""

echo "Began ycsb workload:
roachprod cluster: $name
binary: $binary.o
workers $workers "

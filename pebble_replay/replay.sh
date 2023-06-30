#!/bin/bash
set -e

# This script grabs the target binary from the pebble repo and runs the replay
# bench.

. ./config.sh

trials=$2

pebble_repo="/home/michaelbutler/go/src/github.com/cockroachdb/pebble"
cp $pebble_repo/$1.o $1.o

./$1.o bench replay -v "/mnt/disks/$DISK_NAME/store_1/20230117212340" --name kv0/20gb --stream-logs --count $trials --options "[Options] max_concurrent_compactions=5" --pacer=reference-ramp --max-writes 20480 1>replay_logs/$1.log 2>replay_logs/$1_verbose.log

sudo /usr/sbin/fstrim --fstab --verbose --quiet

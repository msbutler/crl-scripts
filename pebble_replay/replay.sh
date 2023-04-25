#!/bin/bash
set -e

DISK_NAME="$USER-kv0"
pebble_repo="/home/michaelbutler/go/src/github.com/cockroachdb/pebble"
cp $pebble_repo/$1.o $1.o

./$1.o bench replay -v "/mnt/disks/$DISK_NAME/store_1/20230117212340" --name kv0/20gb --stream-logs --count 6 --options "[Options] max_concurrent_compactions=5" --pacer=reference-ramp --max-writes 20480 1>replay_logs/$1.log 2>replay_logs/$1_verbose.log

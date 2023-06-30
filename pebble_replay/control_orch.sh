#!/bin/bash
set -e

# This script runs a the replay bench for the control build of pebble,
# and generates benchstats to compare their results.

rm -rf replay_logs
mkdir replay_logs

./replay.sh control 5

zip -r replay_multi.zip replay_logs

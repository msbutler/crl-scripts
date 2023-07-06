#!/bin/bash
set -e

# This script runs a the replay bench for a couple different builds of pebble,
# and generates benchstats to compare their results.

rm -rf replay_logs
mkdir replay_logs

./replay.sh multi-l0 10
./replay.sh multi 10
./replay.sh control 10

cd replay_logs
benchstat control.log multi.log > bench_control_v_multi.log
benchstat control.log multi-l0.log > bench_control_v_multi-l0.log
benchstat multi.log multi-l0.log > bench_multi_v_multi-l0.log
cd ..

zip -r replay_multi.zip replay_logs

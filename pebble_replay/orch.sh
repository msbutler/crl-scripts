#!/bin/bash
set -e

rm -rf replay_logs
mkdir replay_logs

./replay.sh multi-l0
./replay.sh multi
./replay.sh control

cd replay_logs
benchstat control.log multi.log > bench_control_v_multi.log
benchstat control.log multi-l0.log > bench_control_v_multi-l0.log
benchstat multi.log multi-l0.log > bench_multi_v_multi-l0.log
cd ..

zip -r replay_multi.zip replay_logs

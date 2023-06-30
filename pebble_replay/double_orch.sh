#!/bin/bash
set -e

# this script runs the full bench twice 
./orch.sh
cp -r replay_logs replay_logs_1
cp -r replay_multi.zip replay_multi_1.zip

./orch.sh
cp -r replay_logs replay_logs_2
cp -r replay_multi.zip replay_multi_2.zip
benchstat replay_logs_1/control.log replay_logs_2/control.log > control_v_control_1.log
benchstat replay_logs_1/multi.log replay_logs_2/multi.log > multi_v_multi_1.log

./orch.sh
cp -r replay_logs replay_logs_3
cp -r replay_multi.zip replay_multi_3.zip
benchstat replay_logs_2/control.log replay_logs_3/control.log > control_v_control_2.log
benchstat replay_logs_2/multi.log replay_logs_3/multi.log > multi_v_multi_2.log

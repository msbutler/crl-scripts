#!/bin/bash
set -e

# this script runs the control bench three times 
rm control_v_*
rm replay_logs_* -rf
rm replay_multi*

./control_orch.sh
cp -r replay_logs replay_logs_1
cp -r replay_multi.zip replay_multi_1.zip

./control_orch.sh
cp -r replay_logs replay_logs_2
cp -r replay_multi.zip replay_multi_2.zip
benchstat replay_logs_1/control.log replay_logs_2/control.log > control_v_control_1.log

./control_orch.sh
cp -r replay_logs replay_logs_3
cp -r replay_multi.zip replay_multi_3.zip
benchstat replay_logs_2/control.log replay_logs_3/control.log > control_v_control_2.log

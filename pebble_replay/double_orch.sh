#!/bin/bash
set -e

# this script runs the full bench twice 
./orch.sh
cp -r replay_logs replay_logs_1
cp -r replay_multi.zip replay_multi_1.zip

./orch.sh

benchstat replay_logs_1/control.log replay_logs/control.log > control_v_control.log

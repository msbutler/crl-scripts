#!/bin/bash
set -e

# this script runs the control bench three times 
rm control_v_* -f
rm replay_logs_* -rf
rm replay_multi* -f

# run the main workloads
for (( counter=1; counter<=15; counter++ ))
do
	echo "Counter: $counter"
	rm -rf replay_logs
	mkdir replay_logs

	./replay.sh control 1
	zip -r replay_multi.zip replay_logs
  cp -r replay_logs replay_logs_$counter
  cp -r replay_multi.zip replay_multi_$counter.zip
done

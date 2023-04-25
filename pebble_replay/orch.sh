#!/bin/bash
set -e

rm -rf replay_logs
mkdir replay_logs

./replay multi-l0
./replay multi
./replay control

zip -r replay_multi.zip replay_logs

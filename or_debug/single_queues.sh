#!/bin/bash

set -e

CLUSTER="local"
REPO="/Users/michaelbutler/go/src/github.com/cockroachdb/cockroach"

cd $REPO
roachprod create $CLUSTER --nodes=1 --cloud aws --local-ssd=false --aws-ebs-volume-size=1000
roachprod stage $CLUSTER:1 artifacts/cockroach
roachprod start $CLUSTER
roachprod sql $CLUSTER:1 -- -e "SET CLUSTER SETTING kv.queue.process.guaranteed_time_budget='1h'"
roachprod sql $CLUSTER:1 -- -e "SET CLUSTER SETTING SET CLUSTER SETTING jobs.debug.pausepoints = 'restore.before_do_download_files'"
roachprod adminui $CLUSTER:1
time roachprod sql $CLUSTER:1 -- -e "RESTORE DATABASE tpce FROM LATEST IN 's3://cockroach-fixtures-us-east-2/backups/tpc-e/customers=25000/v23.1.11/inc-count=48/rev-history=false?AUTH=implicit' AS OF SYSTEM TIME '2023-11-08T20:00:44.127379Z' WITH EXPERIMENTAL DEFERRED COPY"

roachprod run $CLUSTER:1 -- "./cockroach debug zip debug.zip --insecure"
roachprod get $CLUSTER:1 debug.zip debug.zip


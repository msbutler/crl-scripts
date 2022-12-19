#!/bin/bash

# This script checks the number of incremental backups that have run in a
# schedule every 5 minutes. If the number exceeds the predifined workload
# amount, the script will cancel the scheduled backup job.

. ./$1.sh
echo "are you running this in a tmux session on your gce worker? Press y"
read confirm
if [[ "$confirm" != "y" ]]; then
  echo "No? I won't let you run this program then"
  exit 0
fi

echo "loading config from $1.sh:
hardware: 
  cluster_name: $cluster_name
  crdb_version: $crdb_version
tpce: 
  tpce_customers: $tpce_customers
  duration: $duration
backup:
  inc_count: $inc_count
  inc_crontab: $inc_crontab
"

collection="gs://cockroach-fixtures/backups/tpc-e/rev-history=true,inc-count=$inc_count,cluster/customers=$tpce_customers/$crdb_version?AUTH=implicit"

while :
do
  # sleep for 300 seconds, aka 5 mins
  sleep 300
  scheduleExists=$(roachprod sql $cluster_name:1 -- -e "SELECT label FROM [SHOW SCHEDULES] WHERE label ='schedule_cluster'")
if [[ $scheduleExists != *"2 row"* ]]; then
  echo "Schedule does not exist"
  exit 0
fi

  backupCount=$(roachprod sql $cluster_name:1 -- -e "SELECT * FROM [SELECT count(DISTINCT end_time) FROM [SHOW BACKUP FROM LATEST IN '$collection']] WHERE count > $inc_count")
  if [[ $backupCount == *"1 row"* ]]; then
    echo "Cancelling schedule"
    roachprod sql $cluster_name:1 -- -e "DROP SCHEDULES WITH x AS (SHOW SCHEDULES) SELECT id FROM x WHERE label = 'schedule_cluster'"
    exit 0
  fi
done

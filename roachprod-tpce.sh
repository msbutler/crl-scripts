#!/bin/bash

# This script can be used to setup a roachprod cluster, init and run the tpce
# workload. I'd recommend the following workflow:
# - run script once to setup the cluster and init the workload
# - wait until the tmux session monitoring initizialation has finished
# - run the script again to setup the backup schedule and the workload, 
#   skipping setup
# 
# To run the script, pass the config file name when executing this script. For
# example, `./roachprod-tpce.sh tpce10TB`
set -e

. ./$1.sh
echo "loading config from $1.sh:
hardware: 
  crdb_nodes: $crdb_nodes 
  cluster_name: $cluster_name
  crdb_version: $crdb_version
  gce_machine_typ: $gce_machine_type
  pd_vol_size: $pd_vol_size  
tpce: 
  tpce_customers: $tpce_customers
  duration: $duration
backup:
  inc_count: $inc_count
  inc_crontab: $inc_crontab
"

exists=$(gsutil ls gs://cockroach-fixtures/tpce-csv/customers=$tpce_customers | wc -l)
if (( $exists == 0 )); then
  echo "$tpce_customers customer fixture does not exist"
  exit 1
fi

echo "setup roachprod cluster? Press y"
read setup
if [[ "$setup" == "y" ]]; then
  roachprod create $cluster_name --nodes=$total_nodes --gce-machine-type=$gce_machine_type --gce-zones=us-central1-a --local-ssd=false --gce-pd-volume-size=$pd_vol_size --gce-min-cpu-platform='Intel Ice Lake'
  roachprod install $cluster_name:$total_nodes docker
  roachprod ip  $cluster_name:1-$crdb_nodes | sed 's/^/--hosts=/' | tr '\n' ' ' > hosts.txt
  roachprod put $cluster_name:$total_nodes hosts.txt
  rm hosts.txt
  roachprod stage $cluster_name:1-$crdb_nodes release $crdb_version
  roachprod start $cluster_name:1-$crdb_nodes --racks=$crdb_nodes
  roachprod adminurl --open $cluster_name:1
  echo "roachprod cluster set up"
fi

echo "init workload? Press y"
read init
if [[ $init == "y" ]]; then
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-import \"sudo docker run cockroachdb/tpc-e:latest --init --customers=$tpce_customers --racks=$crdb_nodes \$(cat hosts.txt)\""
  echo "tpce init has begun. Do not run anything on cluster until
  after init process completes. To observe init script, run: 
  roachprod ssh $cluster_name:$total_nodes
followed by:
  tmux attach-session -t tpce-import "
  exit 0
fi

collection="gs://cockroach-fixtures/backups/tpc-e/rev-history=true,inc-count=$inc_count,cluster/customers=$tpce_customers/$crdb_version?AUTH=implicit"

echo "setup backup schedule? Press y"
read backup
if [[ $backup == "y" ]]; then
  roachprod sql $cluster_name:1 -- -e "ALTER RANGE default CONFIGURE ZONE USING gc.ttlseconds = 90000"
  
  # This backup schedule will first run a full backup immediately and then the
  # incremental backups at the given crontab cadence until the user cancels the
  # backup schedules. To ensure that only one full backup chain gets created,
  # begin the backup schedule at the beginning of the week, as a new full
  # backup will get created on Sunday at Midnight ;)
  #
  # TODO(msbutler) automatically cancel the schedules once desired inc_count
  # gets reached.
  schedule_cmd="CREATE SCHEDULE schedule_cluster FOR BACKUP INTO '$collection' WITH revision_history RECURRING '$inc_crontab' FULL BACKUP '@weekly' WITH SCHEDULE OPTIONS first_run = 'now'"
  echo "$schedule_cmd"
  roachprod sql $cluster_name:1 -- -e "$schedule_cmd"
fi

echo "run tpce workload? Press y"
read run
if [[ $run == "y" ]]; then
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-driver \"sudo docker run cockroachdb/tpc-e:latest --customers=$tpce_customers --racks=$crdb_nodes --duration=$duration \$(cat hosts.txt)\""
fi

if [[ $monitor == "y" ]]; then
  tmux
  scheduleCount=$(roachprod sql $cluster_name:1 -- -e "SELECT * FROM [SELECT count(DISTINCT end_time) FROM [SHOW BACKUP FROM LATEST IN '$collection']] WHERE count > $inc_count")
  echo "Backup Chain Length\n $scheduleCount"
  if [[ $scheduleCount != *"0 rows"* ]]; then
    echo "Cancelling schedule"
    roachprod sql $cluster_name:1 -- -e "DROP SCHEDULES WITH x AS (SHOW SCHEDULES) SELECT id FROM x WHERE label = 'schedule_cluster'"
  fi
fi


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
let total_nodes=$crdb_nodes+1

if [[ "$2" == "help" ]]; then
  echo "This script makes it a bit easier to spin up a roachprod cluster to run
the tpce workload and a backup schedule

Run any of the following commands via:
./roachprod-tpce [config_name] [cmd]

Available commands:
- setup: creates a roachprod cluster that's ready to init a tpc-e workload.
- init: inits a tpce workload.
- run: runs a tpce workload.
- backup: begins a backup schedule that writes to the cockroach-fixtures
  bucket. If $cloud is aws, write s3, else gs.
- monitor: creates a tmux session that counts the number of incremental backups
  in the latest full backup chain. TODO(msbutler): integrate in script
"

echo "config from $1.sh:
hardware: 
  crdb_nodes: $crdb_nodes 
  total_nodes: $total_nodes
  cloud: $cloud
  machine_type: $machine_type
  vol_size: $vol_size GBs
crdb:
  cluster_name: $cluster_name
  crdb_version: $crdb_version
tpce: 
  tpce_customers: $tpce_customers
  duration: $duration
backup:
  inc_count: $inc_count
  inc_crontab: $inc_crontab
"
  exit 0
fi

exists=$(gsutil ls gs://cockroach-fixtures/tpce-csv/customers=$tpce_customers | wc -l)
if (( $exists == 0 )); then
  echo "$tpce_customers customer fixture does not exist"
  exit 1
fi

if [[ "$2" == "setup" ]]; then 
    
    if [[ "$cloud" == "gce" ]]; then
    	roachprod create $cluster_name --nodes=$total_nodes --gce-machine-type=$machine_type --local-ssd=false --gce-pd-volume-size=$vol_size --gce-min-cpu-platform='Intel Ice Lake'
    elif [[ "$cloud" == "aws" ]]; then
	roachprod create $cluster_name --nodes=$total_nodes --aws-machine-type=$machine_type --local-ssd=false --aws-ebs-volume-size=$vol_size
    else
	echo "only aws and gce clouds are supported"
  	exit 1  
  fi
    roachprod install $cluster_name:$total_nodes docker
    roachprod ip  $cluster_name:1-$crdb_nodes | sed 's/^/--hosts=/' | tr '\n' ' ' > hosts.txt
    roachprod put $cluster_name:$total_nodes hosts.txt
    rm hosts.txt
    roachprod stage $cluster_name:1-$crdb_nodes release $crdb_version
    roachprod start $cluster_name:1-$crdb_nodes --racks=$crdb_nodes
    roachprod extend $cluster_name -l 48
    echo "roachprod cluster $cluster_name  is set up"
fi

if [[ "$2" == "init" ]]; then 
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-import \"sudo docker run cockroachdb/tpc-e:latest --init --customers=$tpce_customers --racks=$crdb_nodes \$(cat hosts.txt)\""
  echo "tpce init has begun. Do not run anything on cluster until
  after init process completes. To observe init script, run: 
  roachprod ssh $cluster_name:$total_nodes
followed by:
  tmux attach-session -t tpce-import "
  exit 0
fi

prefix="gs"
if [[ $cloud == "aws" ]]; then
  prefix="s3"
fi

collection="$prefix://cockroach-fixtures/backups/tpc-e/customers=$tpce_customers/$crdb_version/inc-count=$inc_count?AUTH=implicit"

if [[ "$2" == "backup" ]]; then
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

if [[ "$2" == "run" ]]; then
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-driver \"sudo docker run cockroachdb/tpc-e:latest --customers=$tpce_customers --racks=$crdb_nodes --duration=$duration \$(cat hosts.txt)\""
fi


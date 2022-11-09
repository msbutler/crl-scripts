#!/bin/bash
set -e

# roachprod config
crdb_nodes=3
let total_nodes=$crdb_nodes+1
cluster_name=$CLUSTER-22
crdb_version=v22.2.0-rc.1
pd_vol_size=250

# tpc-e config
tpce_customers=5000

duration=23h
active_customers=100000

echo "setup roachprod cluster? Press y"
read setup
if [[ "$setup" == "y" ]]; then
  roachprod create $cluster_name --nodes=$total_nodes --gce-machine-type=n2-standard-48 --gce-zones=us-central1-a --local-ssd=false --gce-pd-volume-size=$pd_vol_size --gce-min-cpu-platform='Intel Ice Lake'
  roachprod install $cluster_name:$total_nodes docker
  roachprod ip  $cluster_name:1-$crdb_nodes | sed 's/^/--hosts=/' | tr '\n' ' ' > hosts.txt
  roachprod put $cluster_name:$total_nodes hosts.txt
  rm hosts.txt
  roachprod stage $cluster_name:1-$crdb_nodes release $crdb_version
  roachprod start $cluster_name:1-$crdb_nodes --racks=$crdb_nodes
  roachprod adminurl --open $cluster_name:1
fi

echo "roachprod cluster created. Ready to init workload($tpce_customers customers)? Press y"
read init
if [[ $init == "y" ]]; then
  roachprod run $cluster_name:$total_nodes -- "\'tmux new -d -s tpce-import
\"sudo docker run cockroachdb/tpc-e:latest --init --customers=$tpce_customers
--racks=$crdb_nodes \$(cat hosts.txt)\"\'"
  echo "To observe init script, run: \n roachprod ssh
$cluster_name:$total_nodes\n tmux attach-session tpce-import "
fi

echo "run tpce workload ($active_customers active_customers, with $duration
duration)? Press y"
read run
if [[ $run=="y" ]]; then
  roachprod run $cluster_name:$total_nodes -- 'tmux new -d -s tpce-driver "sudo docker run cockroachdb/tpc-e:latest --customers=$tpce_customers --active-customers=$active_customers --threads=256 --racks=$crdb_nodes --duration=$active_customers $(cat hosts.txt)"’
fi

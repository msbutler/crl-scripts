#!/bin/bash
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
"

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

echo "Ready to init workload? Press y"
read init
if [[ $init == "y" ]]; then
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-import \"sudo docker run cockroachdb/tpc-e:latest --init --customers=$tpce_customers --racks=$crdb_nodes \$(cat hosts.txt)\""
  echo "To observe init script, run: 
  roachprod ssh $cluster_name:$total_nodes
followed by:
  tmux attach-session -t tpce-import "
fi

echo "run tpce workload? Press y"
read run
if [[ $run == "y" ]]; then
  roachprod run $cluster_name:$total_nodes -- "tmux new -d -s tpce-driver \"sudo docker run cockroachdb/tpc-e:latest --customers=$tpce_customers --racks=$crdb_nodes --duration=$duration \$(cat hosts.txt)\""
fi


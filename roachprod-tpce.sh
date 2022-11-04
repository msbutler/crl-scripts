#!/bin/bash
set -e

crdb_nodes=6
let total_nodes=$crdb_nodes+1
cluster_name=$CLUSTER
crdb_version=v22.1.8
pd_vol_size=2500
tpce_customers=500000

roachprod create $cluster_name --nodes=$total_nodes --gce-machine-type=n2-standard-48 --gce-zones=us-central1-a --local-ssd=false --gce-pd-volume-size=$pd_vol_size --gce-min-cpu-platform='Intel Ice Lake'
roachprod install $cluster_name:$total_nodes docker
roachprod ip  $cluster_name:1-$crdb_nodes | sed 's/^/--hosts=/' | tr '\n' ' ' > hosts.txt
roachprod put $cluster_name:$total_nodes hosts.txt
rm hosts.txt
roachprod stage $cluster_name:1-$crdb_nodes release $crdb_version
roachprod start $cluster_name:1-$crdb_nodes --racks=$crdb_nodes
roachprod adminurl --open $cluster_name:1

echo "roachprod cluster created. Ready to init workload($tpce_customers customers)? Press y"
read init
if [[$init=="y"]]
then
roachprod run $cluster_name:$total_nodes -- 'tmux new -d -s tpce-import "sudo docker run cockroachdb/tpc-e:latest --init --customers=$tpce_customers --racks=$crdb_nodes $(cat hosts.txt)"'


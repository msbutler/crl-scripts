#!/bin/bash

# 100GB TPCE config

# hardware
crdb_nodes=4
let total_nodes=$crdb_nodes+1
cluster_name=$CLUSTER-22
crdb_version=v22.2.0-rc.3
gce_machine_type=n2-standard-8
pd_vol_size=1000

# tpce init; creates about 80GB of data
tpce_customers=5000

# tpce run
duration=1m



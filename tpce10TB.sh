#!/bin/bash

# 10TB TPCE config

# hardware
crdb_nodes=15
let total_nodes=$crdb_nodes+1
cluster_name=$CLUSTER-22
crdb_version=v22.2.0-rc.3
gce_machine_type=n2-standard-32
pd_vol_size=3000

# tpce init
tpce_customers=500000

# scheduled backup (runs every 15 minutes)
inc_count=96
inc_crontab="*/15 * * * *"

# tpce run
duration=48h



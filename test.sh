#!/bin/bash

# test config

# hardware
crdb_nodes=3
let total_nodes=$crdb_nodes+1
cluster_name=$CLUSTER-test
crdb_version=v22.2.0-rc.3
gce_machine_type=n2-standard-8
pd_vol_size=100

tpce_customers=1000

# scheduled backup (runs every 15 minutes)
inc_count=3
inc_crontab="*/1 * * * *"

# tpce run
duration="5m"



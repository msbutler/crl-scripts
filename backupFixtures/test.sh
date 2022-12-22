#!/bin/bash

. ./default.sh

# hardware
crdb_nodes=1
cluster_name=$CLUSTER-test
vol_size=100
cloud=gce
machine_type=n2-standard-4

tpce_customers=1000

# scheduled backup (runs every 15 minutes)
inc_count=8
inc_crontab="*/1 * * * *"

# tpce run
duration=5m



#!/bin/bash

. ./default.sh

# hardware
crdb_nodes=3
cluster_name=$CLUSTER-test
vol_size=100

tpce_customers=1000

# scheduled backup (runs every 15 minutes)
inc_count=3
inc_crontab="*/1 * * * *"

# tpce run
duration=5m



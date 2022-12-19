#!/bin/bash

#default roachtest config

# hardware
crdb_nodes=4
cluster_name=$CLUSTER-default
crdb_version=v22.2.0
cloud=aws
machine_type=n2-standard-8
vol_size=1000

# tpce init; creates about ?GB of data
tpce_customers=25000

# scheduled backup (runs every 15 minutes, for 12 hours once the full completes)
inc_count=48
inc_crontab="*/15 * * * *"

# tpce run
duration=23h



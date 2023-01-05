#!/bin/bash

#default roachtest config

# hardware
crdb_nodes=4
cluster_name=$CLUSTER-default
crdb_version=v22.2.1
cloud=aws
machine_type=m5.xlarge
vol_size=1000

# tpce init; creates about 400GB of data
tpce_customers=25000

# scheduled backup (runs every 15 minutes, for 12 hours once the full completes)
inc_count=48
inc_crontab="*/15 * * * *"
auth="?AUTH=implicit"

# tpce run
duration=23h



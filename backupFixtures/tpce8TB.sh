#!/bin/bash

# 8TB TPCE config

# load default configs and only change non-default settings for this fixture
. ./default.sh

# hardware
crdb_nodes=15
cluster_name=$CLUSTER-8TB
machine_type=n2-standard-32
vol_size=3000

# tpce init
tpce_customers=500000

# tpce run (configure to run  longer as full backup will take a couple # hours)
duration=48h


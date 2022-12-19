#!/bin/bash

# 80GB TPCE config
. ./default.sh

# hardware
cluster_name=$CLUSTER-80GB
crdb_version=v22.2.0-rc.3
vol_size=100

# tpce init; creates about 80GB of data
tpce_customers=5000


#!/bin/bash

# 45TB TPCE config

# load default configs and only change non-default settings for this fixture
. ./default.sh

# hardware
crdb_nodes=15
cluster_name=$CLUSTER-45tb
machine_type=n2-standard-48
vol_size=5000
cloud=aws

# tpce init
tpce_customers=2000000

# tpce run (configure to run  longer as full backup will take a couple # hours)
duration=72h

# backup
auth="?AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY&AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY"


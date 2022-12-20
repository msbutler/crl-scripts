#!/bin/bash

#default roachtest config

. ./default.sh

# hardware
cluster_name=$CLUSTER-gcs-default
cloud=gce
machine_type=n2-standard-8


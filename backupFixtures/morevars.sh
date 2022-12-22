#!/bin/bash

# loads the config to introduce more variable required to run the scripts
. ./$1.sh

let total_nodes=$crdb_nodes+1

prefix="gs"
if [[ $cloud == "aws" ]]; then
  prefix="s3"
fi

collection="$prefix://cockroach-fixtures/backups/tpc-e/customers=$tpce_customers/$crdb_version/inc-count=$inc_count?AUTH=implicit"

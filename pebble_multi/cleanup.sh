#!/bin/bash
set -e

binary=$1
workers=$2
name=$CLUSTER-$binary-$workers
dir=$binary-$workers
echo "$dir"
mkdir -p $dir  
roachprod get $name output.txt $dir/output.txt 
roachprod get $name verbose.txt $dir/verbose.txt



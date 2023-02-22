#!/bin/bash
set -e

binary=$1
workers=$2
name=$CLUSTER-$binary-$workers
dir=$binary-$workers
echo "$dir"
mkdir -p res/$dir  
roachprod get $name output.txt res/$dir/output.txt 
roachprod get $name verbose.txt res/$dir/verbose.txt
roachprod destroy $name




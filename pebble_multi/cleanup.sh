#!/bin/bash
set -e

name=$CLUSTER-$binary-$workers
mkdir $name
roachprod get $name output.txt $name/output.txt 
roachprod get $name verbose.txt $name/output.txt



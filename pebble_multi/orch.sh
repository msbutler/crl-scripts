#!/bin/bash
set -e

roachprod list | grep "butler"
./$1.sh control 96 verbose
./$1.sh control 128 verbose
./$1.sh multi 96 verbose
./$1.sh multi 128 verbose
./$1.sh multi-counter-l0 96 verbose
./$1.sh multi-counter-l0 128 verbose
./$1.sh multi-l0 96 verbose
./$1.sh multi-l0 128 verbose

if [[ "$1" == "cleanup" ]]; then
  zip -r res.zip res
fi


#!/bin/bash
set -e

roachprod list | grep "butler"
./$1.sh control 96 verbose
./$1.sh control 124 verbose
./$1.sh multi 96 verbose
./$1.sh multi 124 verbose
./$1.sh multi-counter-l0 96 verbose
./$1.sh multi-l0 96 verbose
./$1.sh multi-l0 124 verbose


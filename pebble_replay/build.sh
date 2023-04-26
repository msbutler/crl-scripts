#!/bin/bash
set -e

#build test branches

pwd=$(pwd)
pebble_repo="/home/michaelbutler/go/src/github.com/cockroachdb/pebble"
cd $pebble_repo
git switch butler-metrics-explore

# with all commits, build multi level with l0 input
go build -o multi-l0.o ./cmd/pebble

# remove top commit and buiild with l0 input
git reset HEAD~1 --hard
go build -o multi.o ./cmd/pebble

# remove top commit and build control
git reset HEAD~1 --hard
go build -o control.o ./cmd/pebble

git fetch
git reset --hard @{u}

cd $pwd





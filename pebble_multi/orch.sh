#!/bin/bash
set -e

./pebble.sh control 124 verbose
./pebble.sh multi 96 verbose
./pebble.sh multi 124 verbose
./pebble.sh multi-counter-l0 96 verbose
./pebble.sh multi-l0 96 verbose
./pebble.sh multi-l0 124 verbose


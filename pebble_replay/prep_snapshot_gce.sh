#!/bin/bash
set -e

. ./config.sh

sudo mkdir -p "/mnt/disks/$DISK_NAME"
sudo mount -o ro,noload,discard,defaults "/dev/disk/by-id/google-$DISK_NAME" \
     "/mnt/disks/$DISK_NAME"

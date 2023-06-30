#!/bin/bash
set -e

. ./config.sh
echo $DISK_NAME

gcloud compute instances attach-disk "gceworker-$USER" --disk="$DISK_NAME" \
  --device-name "$DISK_NAME" --project cockroach-workers

#!/bin/bash
set -e

echo $DISK_NAME

gcloud compute instances attach-disk "gceworker-$USER" --disk="$DISK_NAME" \
  --device-name "$DISK_NAME" --project cockroach-workers

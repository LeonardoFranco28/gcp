#!/bin/bash
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : three standalone web servers for the network LB
for i in 1 2 3; do
  gcloud compute instances create web$i \
    --zone="$ZONE" \
    --network=default \
    --machine-type=e2-small \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=network-lb-tag \
    --metadata-from-file=startup-script=scripts/startup-script.sh
done

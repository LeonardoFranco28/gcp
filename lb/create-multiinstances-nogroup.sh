#!/bin/bash
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : three standalone web servers for the network LB
for i in 1 2 3; do
  # lab expects the literal name (web1..web3) in the script, not $HOSTNAME
  f=$(mktemp); sed "s/\$HOSTNAME/web$i/" scripts/startup-script.sh > "$f"
  gcloud compute instances create web$i \
    --zone="$ZONE" \
    --network=default \
    --machine-type=e2-small \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=network-lb-tag \
    --metadata-from-file=startup-script="$f" || { rm -f "$f"; exit 1; }
  rm -f "$f"
done

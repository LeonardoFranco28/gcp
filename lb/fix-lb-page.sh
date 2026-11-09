#!/bin/bash
# Rewrites the Apache page on the running MIG VMs to "Page served from: <instance name>".
# Quick fix when the VMs were created from a template with the old startup script.
# It does NOT change the template: new VMs would still get the old page.
source "$(dirname "$0")/env.sh" || exit 1

for vm in $(gcloud compute instance-groups managed list-instances lb-backend-group \
    --zone="$ZONE" --format='value(instance.basename())'); do
  echo "-- $vm"
  gcloud compute ssh "$vm" --zone="$ZONE" --quiet --command \
    'echo "Page served from: $(curl -s -H "Metadata-Flavor:Google" http://metadata.google.internal/computeMetadata/v1/instance/name)" | sudo tee /var/www/html/index.html' \
    || echo "   (failed: $vm)"
done

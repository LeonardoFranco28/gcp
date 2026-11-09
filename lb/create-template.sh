#!/bin/bash
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : global template for the managed instance group
# (no --instance-template-region: the lab checker expects a global template)
gcloud compute instance-templates create lb-backend-template \
  --network=default \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-standard \
  --tags=allow-health-check \
  --metadata-from-file=startup-script=scripts/startup-script.sh

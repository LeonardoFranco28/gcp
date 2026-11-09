#!/bin/bash
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : managed instance group with 3 instances (named lb-backend-group-xxxx)
gcloud compute instance-groups managed create lb-backend-group \
  --base-instance-name lb-backend-group \
  --size 3 \
  --template lb-backend-template \
  --zone "$ZONE"

# Task 2 : named port "http" must match --port-name of the backend service
gcloud compute instance-groups managed set-named-ports lb-backend-group \
  --zone "$ZONE" \
  --named-ports http:80

#!/bin/bash
source "$(dirname "$0")/env.sh" || exit 1

#Task 1 : allow HTTP to the standalone VMs (network LB)
gcloud compute firewall-rules create www-firewall-network-lb \
  --network=default \
  --allow=tcp:80 \
  --direction=INGRESS \
  --priority=1000 \
  --target-tags=network-lb-tag \
  --source-ranges=0.0.0.0/0

#Task 2 : allow Google health checkers to the MIG VMs (HTTP LB)
gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=INGRESS \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

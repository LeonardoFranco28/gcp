#!/bin/bash
# Network LB (regional, TCP) for the standalone VMs web1..web3 (tag network-lb-tag).
# Needs create-firewall-rules.sh and create-multiinstances-nogroup.sh first.
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : Static external IP
gcloud compute addresses create network-lb-ip-1 --region="$REGION"

# Task 2 : Legacy HTTP health check
gcloud compute http-health-checks create basic-check

# Task 3 : Target pool with the health check
gcloud compute target-pools create www-pool \
  --region="$REGION" \
  --http-health-check=basic-check

# Task 4 : Add the VMs to the pool
gcloud compute target-pools add-instances www-pool \
  --instances=web1,web2,web3 \
  --instances-zone="$ZONE"

# Task 5 : Forwarding rule
gcloud compute forwarding-rules create www-rule \
  --region="$REGION" \
  --ports=80 \
  --address=network-lb-ip-1 \
  --target-pool=www-pool

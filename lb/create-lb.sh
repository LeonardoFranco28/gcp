#!/bin/bash
# Classic global external HTTP load balancer.
source "$(dirname "$0")/env.sh" || exit 1

# Task 1 : Create a LB IP address
gcloud compute addresses create lb-ipv4-1 --ip-version=IPV4 --global

# Task 2 : Create a health check
gcloud compute health-checks create http http-basic-check --port=80

# Task 3 : Create a Backend service
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

# Task 4 : Add the instance group to the backend service
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone="$ZONE" \
  --global

# Task 5 : Create a URL map to route all requests to the backend service
gcloud compute url-maps create web-map-http --default-service=web-backend-service

# Task 6 : Create a target HTTP proxy to route requests to the URL map
gcloud compute target-http-proxies create http-lb-proxy --url-map=web-map-http

# Task 7 : Create a global forwarding rule that sends port 80 traffic to the proxy
gcloud compute forwarding-rules create http-content-rule \
  --address=lb-ipv4-1 \
  --global \
  --target-http-proxy=http-lb-proxy \
  --ports=80

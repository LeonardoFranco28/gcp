#!/bin/bash
# Curls each web VM, the network LB and the HTTP LB.
source "$(dirname "$0")/env.sh" || exit 1

echo "== web1..web3 =="
for i in 1 2 3; do
  ip=$(gcloud compute instances describe web$i --zone="$ZONE" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
  echo -n "web$i ($ip): "; curl -s --max-time 5 "http://$ip" || echo "no response (try resetting the VM)"
done

echo "== Network LB (6 requests, should vary) =="
nlb=$(gcloud compute forwarding-rules describe www-rule --region="$REGION" --format='get(IPAddress)')
for i in $(seq 6); do curl -s --max-time 5 "http://$nlb"; done

echo "== HTTP LB (retries up to ~5 min) =="
lb=$(gcloud compute addresses describe lb-ipv4-1 --global --format='get(address)')
for i in $(seq 10); do
  if out=$(curl -sf --max-time 5 "http://$lb"); then echo "$lb -> $out"; exit 0; fi
  echo "not ready yet, retry $i/10"; sleep 30
done
echo "HTTP LB did not answer; check backend health in the console." >&2
exit 1

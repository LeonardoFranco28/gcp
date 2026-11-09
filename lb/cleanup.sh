#!/bin/bash
# Deletes every resource created by the scripts in lb/, in reverse dependency order.
# Only touches the fixed names below. Missing resources are skipped.
# Usage: bash cleanup.sh        (asks for confirmation)
#        bash cleanup.sh -y     (no prompt; -y can go anywhere, e.g. --zone Z -y)
source "$(dirname "$0")/env.sh" || exit 1

yes=""; for a in "$@"; do [ "$a" = "-y" ] && yes=1; done
if [ -z "$yes" ]; then
  read -r -p "Delete ALL lab resources in project $PROJECT_ID ($REGION / $ZONE)? [y/N] " ans
  [ "$ans" = "y" ] || { echo "Aborted."; exit 1; }
fi

del() { echo "-- $*"; gcloud compute "$@" --quiet || echo "   (skipped: not found or already deleted)"; }

# HTTP LB (reverse of create-lb.sh / create-instance-groups.sh / create-template.sh)
del forwarding-rules delete http-content-rule --global
del target-http-proxies delete http-lb-proxy
del url-maps delete web-map-http
del backend-services delete web-backend-service --global
del health-checks delete http-basic-check
# MIG and VMs: look them up in any zone (the lab may not use the default one)
for z in $(gcloud compute instance-groups managed list --filter="name=lb-backend-group" --format='value(zone.basename())'); do
  del instance-groups managed delete lb-backend-group --zone="$z"
done
del instance-templates delete lb-backend-template
del addresses delete lb-ipv4-1 --global

# Network LB (reverse of create-network-lb.sh / create-multiinstances-nogroup.sh)
del forwarding-rules delete www-rule --region="$REGION"
del target-pools delete www-pool --region="$REGION"
del http-health-checks delete basic-check
del addresses delete network-lb-ip-1 --region="$REGION"
gcloud compute instances list --filter='name~^web[123]$' --format='value(name,zone.basename())' |
  while read -r n z; do del instances delete "$n" --zone="$z"; done

# Firewall rules
del firewall-rules delete www-firewall-network-lb
del firewall-rules delete fw-allow-health-check

echo "Cleanup done."

#!/bin/bash
# Rebuilds the HTTP LB stack (LB, MIG, template) so the template uses the lab's
# "Page served from: <instance>" startup script. Templates cannot be edited, so
# everything that depends on lb-backend-template is deleted and recreated.
# web1..web3 and the network LB are not touched. lb-ipv4-1 gets a new IP.
# Usage: bash fix-lb-template.sh        (asks for confirmation)
#        bash fix-lb-template.sh -y     (no prompt; -y must come first)
source "$(dirname "$0")/env.sh" || exit 1

if [ "$1" != "-y" ]; then
  read -r -p "Delete and recreate HTTP LB, MIG and template in $PROJECT_ID ($ZONE)? [y/N] " ans
  [ "$ans" = "y" ] || { echo "Aborted."; exit 1; }
fi

# Make sure the template uses the right startup script (idempotent).
cat > scripts/lb-backend-startup.sh <<'E'
#!/bin/bash
apt-get update
apt-get install apache2 -y
a2ensite default-ssl
a2enmod ssl
vm_hostname="$(curl -H "Metadata-Flavor:Google" http://metadata.google.internal/computeMetadata/v1/instance/name)"
echo "Page served from: $vm_hostname" | tee /var/www/html/index.html
systemctl restart apache2
E
sed -i 's#startup-script=scripts/startup-script.sh#startup-script=scripts/lb-backend-startup.sh#' create-template.sh

del() { echo "-- $*"; gcloud compute "$@" --quiet || echo "   (skipped: not found)"; }

# reverse dependency order
del forwarding-rules delete http-content-rule --global
del target-http-proxies delete http-lb-proxy
del url-maps delete web-map-http
del backend-services delete web-backend-service --global
del health-checks delete http-basic-check
del addresses delete lb-ipv4-1 --global
del instance-groups managed delete lb-backend-group --zone="$ZONE"
del instance-templates delete lb-backend-template

set -e
bash create-template.sh
bash create-instance-groups.sh
bash create-lb.sh

echo "Done. Wait 3-5 min, then: curl -s http://\$(gcloud compute addresses describe lb-ipv4-1 --global --format='get(address)')"

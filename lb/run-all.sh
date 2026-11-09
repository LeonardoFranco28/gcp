#!/bin/bash
# Runs every task in dependency order. Stops at the first failure.
set -e
cd "$(dirname "$0")"

bash create-firewall-rules.sh          # Tasks 1 + 3 firewalls
bash create-multiinstances-nogroup.sh  # Task 1 web1..web3
bash create-network-lb.sh              # Task 2
bash create-template.sh                # Task 3 template
bash create-instance-groups.sh         # Task 3 MIG
bash create-lb.sh                      # Task 3 HTTP LB

echo "Done. Wait 3-5 min, then: bash verify.sh"

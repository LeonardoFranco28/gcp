# Challenge lab: network LB + HTTP LB

Scripts for the skills.google.com challenge lab. They create web servers, a
network load balancer and a classic global HTTP load balancer.

## Settings

`env.sh` resolves `PROJECT_ID`, `ZONE` and `REGION` in this order: flag, env
var, `gcloud config`, then the lab default (`us-east4-c`; `REGION` is derived
from `ZONE`). `PROJECT_ID` has no default.

```bash
bash run-all.sh --project <lab project> --zone us-east4-c --region us-east4
# or
export PROJECT_ID=<lab project> ZONE=us-east4-c REGION=us-east4
bash run-all.sh
```

Every script accepts the same flags (`--zone=x` form too). A `--zone` without
`--region` derives the region from the zone.

Run from `lb/` (the scripts `cd` there themselves).

## Run

```bash
bash run-all.sh      # everything in order
bash verify.sh       # curl VMs, network LB, HTTP LB
```

| Task | Script | Creates |
|---|---|---|
| 1 | `create-firewall-rules.sh` | `www-firewall-network-lb` (tcp:80, tag `network-lb-tag`), `fw-allow-health-check` (130.211.0.0/22, 35.191.0.0/16, tag `allow-health-check`) |
| 1 | `create-multiinstances-nogroup.sh` | `web1..web3`, e2-small, debian-12, tag `network-lb-tag`, Apache via `scripts/startup-script.sh` |
| 2 | `create-network-lb.sh` | `network-lb-ip-1`, `basic-check`, `www-pool`, `www-rule` (port 80) |
| 3 | `create-template.sh` | global `lb-backend-template`, e2-medium, tag `allow-health-check` |
| 3 | `create-instance-groups.sh` | MIG `lb-backend-group` (3 VMs named `lb-backend-group-xxxx`), named port `http:80` |
| 3 | `create-lb.sh` | `lb-ipv4-1`, `http-basic-check`, `web-backend-service`, `web-map-http`, `http-lb-proxy`, `http-content-rule` |

## Design notes

- Classic HTTP LB (no `EXTERNAL_MANAGED`, no `beta`, no IPv6 preference).
- Template is global. A regional template (`--instance-template-region`) may
  not be found by the lab checker.
- MIG named port `http` matches the backend service `--port-name=http`. If they
  differ, backends stay unhealthy.
- Instance names `lb-backend-group-xxxx` come from `--base-instance-name`, as in
  the lab's expected page.
- `web1..3` get `scripts/startup-script.sh` with the literal name
  (`Web Server: web1`). The MIG template uses `scripts/lb-backend-startup.sh`,
  which prints `Page served from: <instance name>` as the lab expects.

## Known limits

- Not run against a real project; only syntax-checked (`bash -n`).
- Health check is not attached to the MIG as autohealing (the lab does not ask).
- HTTP LB takes 3-5 minutes to answer after creation.
- Resource names (`www-pool`, `www-rule`, `http-content-rule`, ...) not fixed
  by the lab may need adjusting if the checker expects other names.

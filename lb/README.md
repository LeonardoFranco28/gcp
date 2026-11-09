# Challenge lab: network LB + HTTP LB

Scripts for the skills.google.com challenge lab. They create web servers, a
network load balancer and a classic global HTTP load balancer.

## Settings

`env.sh` reads `PROJECT_ID`, `ZONE` and `REGION`. The lab assigns them, so set
them from the lab panel. If unset, `gcloud config` is used, and `REGION` is
derived from `ZONE`.

```bash
export PROJECT_ID=<lab project>
export ZONE=<lab zone>        # e.g. xx-yyyyN-a
export REGION=<lab region>    # optional, derived from ZONE
```

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
- Startup script prints `Web Server: $HOSTNAME`, which equals the instance
  name (web1, web2, web3), so it matches the lab's text.

## Known limits

- Not run against a real project; only syntax-checked (`bash -n`).
- Health check is not attached to the MIG as autohealing (the lab does not ask).
- HTTP LB takes 3-5 minutes to answer after creation.
- Resource names (`www-pool`, `www-rule`, `http-content-rule`, ...) not fixed
  by the lab may need adjusting if the checker expects other names.

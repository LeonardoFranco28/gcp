#!/bin/bash
# Shared lab settings. Sourced by every script; do not run it directly.
# Override with flags (bash run-all.sh --project P --zone Z --region R) or env vars.
# Defaults: gcloud config, then zone us-east4-c; REGION is derived from ZONE if unset.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Precedence: --flag > exported env var > saved .lab-env > gcloud config > lab default.
# Flags: --project ID  --zone Z  --region R  (also --flag=value). Unknown args are ignored.
args=("$@"); i=0
while [ "$i" -lt "${#args[@]}" ]; do
  case "${args[i]}" in
    --project=*) A_PROJECT="${args[i]#*=}" ;;
    --zone=*)    A_ZONE="${args[i]#*=}" ;;
    --region=*)  A_REGION="${args[i]#*=}" ;;
    --project)   A_PROJECT="${args[i+1]}"; i=$((i+1)) ;;
    --zone)      A_ZONE="${args[i+1]}";    i=$((i+1)) ;;
    --region)    A_REGION="${args[i+1]}";  i=$((i+1)) ;;
  esac
  i=$((i+1))
done
[ -n "$A_PROJECT" ] && PROJECT_ID="$A_PROJECT"
[ -n "$A_ZONE" ] && ZONE="$A_ZONE"
[ -n "$A_REGION" ] && REGION="$A_REGION"
# a zone given by flag implies its region unless a region was also given
[ -n "$A_ZONE" ] && [ -z "$A_REGION" ] && REGION="${ZONE%-*}"

# Remember an explicit zone/region so later runs (cleanup, verify) need no flags.
if [ -n "$A_ZONE$A_REGION" ]; then
  printf 'S_ZONE=%q\nS_REGION=%q\n' "$ZONE" "$REGION" > "$LAB_DIR/.lab-env"
fi
[ -f "$LAB_DIR/.lab-env" ] && . "$LAB_DIR/.lab-env"
ZONE="${ZONE:-$S_ZONE}"
REGION="${REGION:-$S_REGION}"

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
ZONE="${ZONE:-$(gcloud config get-value compute/zone 2>/dev/null)}"
ZONE="${ZONE:-us-east4-c}"   # lab default
REGION="${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}"
REGION="${REGION:-${ZONE%-*}}"

for v in PROJECT_ID REGION ZONE; do
  if [ -z "${!v}" ]; then
    echo "ERROR: $v is not set. Run: export $v=<value from the lab panel>" >&2
    return 1 2>/dev/null || exit 1
  fi
done

# gcloud picks these up, so commands need no --project flag
export CLOUDSDK_CORE_PROJECT="$PROJECT_ID"
export CLOUDSDK_COMPUTE_REGION="$REGION"
export CLOUDSDK_COMPUTE_ZONE="$ZONE"
export PROJECT_ID REGION ZONE LAB_DIR

# Also persist them in gcloud config so manual gcloud commands use the same values.
# Done once per run (LAB_CFG_DONE is inherited by the child scripts of run-all.sh).
if [ -z "$LAB_CFG_DONE" ]; then
  gcloud config set project "$PROJECT_ID" --quiet >/dev/null 2>&1
  gcloud config set compute/region "$REGION" --quiet >/dev/null 2>&1
  gcloud config set compute/zone "$ZONE" --quiet >/dev/null 2>&1
  export LAB_CFG_DONE=1
fi

# startup-script path is relative to lb/
cd "$LAB_DIR" || return 1 2>/dev/null || exit 1
echo ">> project=$PROJECT_ID region=$REGION zone=$ZONE"

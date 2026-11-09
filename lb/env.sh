#!/bin/bash
# Shared lab settings. Sourced by every script; do not run it directly.
# Override with: PROJECT_ID=... REGION=... ZONE=... bash run-all.sh
# Otherwise values come from gcloud config; REGION is derived from ZONE if unset.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
ZONE="${ZONE:-$(gcloud config get-value compute/zone 2>/dev/null)}"
REGION="${REGION:-$(gcloud config get-value compute/region 2>/dev/null)}"
[ -z "$REGION" ] && [ -n "$ZONE" ] && REGION="${ZONE%-*}"

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

# startup-script path is relative to lb/
cd "$LAB_DIR" || return 1 2>/dev/null || exit 1
echo ">> project=$PROJECT_ID region=$REGION zone=$ZONE"

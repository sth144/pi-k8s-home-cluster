#!/bin/bash
set -euo pipefail

# CHANGED: create/update Pi-hole secret from local .env without committing password.
if [ -f ./.env ]; then
  set -a
  . ./.env
  set +a
fi

: "${PIHOLE_PASSWORD:?Set PIHOLE_PASSWORD in pihole/.env}"

kubectl create secret generic pihole-secrets \
  --from-literal=PIHOLE_PASSWORD="$PIHOLE_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

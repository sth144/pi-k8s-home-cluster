#!/bin/bash
set -euo pipefail

# CHANGED: load local .env (if present) so token is not passed via committed files.
if [ -f ./.env ]; then
  set -a
  . ./.env
  set +a
fi

if [ -z "${RUNNER_REGISTRATION_TOKEN:-}" ] && [ -f ./.env.REGISTRATION_TOKEN ]; then
  RUNNER_REGISTRATION_TOKEN="$(cat ./.env.REGISTRATION_TOKEN)"
fi

: "${RUNNER_REGISTRATION_TOKEN:?Set RUNNER_REGISTRATION_TOKEN in .env or .env.REGISTRATION_TOKEN}"

# CHANGED: use upgrade --install for idempotent reruns.
helm upgrade --install k8s-runner gitlab/gitlab-runner \
  --set gitlabUrl=https://gitlab.sth144.duckdns.org \
  --set-string runnerRegistrationToken="$RUNNER_REGISTRATION_TOKEN" \
  -f values.yaml

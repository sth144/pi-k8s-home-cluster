#!/bin/bash
set -euo pipefail

# Low-risk image upgrade workflow:
# 1) plan    - list current images and suggest review order (default)
# 2) validate - run kubectl client dry-run against all manifests
# 3) apply <manifest...> - apply only explicit manifests after review

MODE="${1:-plan}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

list_images() {
  find "$ROOT_DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) \
    -not -path '*/.git/*' \
    -print0 | xargs -0 grep -Hn '^[[:space:]]*image:' | sort
}

validate_manifests() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl not found; cannot run dry-run validation"
    exit 1
  fi

  local failed=0
  while IFS= read -r file; do
    if ! kubectl apply --dry-run=client -f "$file" >/dev/null 2>&1; then
      echo "validation failed: $file"
      failed=1
    fi
  done < <(find "$ROOT_DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) -not -path '*/.git/*' | sort)

  if [ "$failed" -eq 0 ]; then
    echo "all manifests passed kubectl --dry-run=client"
  else
    exit 1
  fi
}

case "$MODE" in
  plan)
    echo "Current image references:"
    list_images
    echo
    echo "Suggested low-risk process:"
    echo "1. Update one service image tag at a time."
    echo "2. Run: $0 validate"
    echo "3. Apply only touched manifests: $0 apply <manifest...>"
    ;;
  validate)
    validate_manifests
    ;;
  apply)
    shift
    if [ "$#" -eq 0 ]; then
      echo "usage: $0 apply <manifest...>"
      exit 1
    fi
    if ! command -v kubectl >/dev/null 2>&1; then
      echo "kubectl not found; cannot apply manifests"
      exit 1
    fi
    for manifest in "$@"; do
      kubectl apply -f "$manifest"
    done
    ;;
  *)
    echo "unknown mode: $MODE"
    echo "usage: $0 [plan|validate|apply <manifest...>]"
    exit 1
    ;;
esac

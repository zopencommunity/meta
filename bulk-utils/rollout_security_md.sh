#!/bin/bash
# Title: Add SECURITY.md to a single repo if it doesn't already have one
#
# Executed by multi-gitter inside each cloned zopencommunity repo — do NOT run directly.
# multi-gitter clones the target repo, runs this script at its root, commits
# any changes, and opens a PR. The REPOSITORY env var (owner/name) is set by multi-gitter.
#
# To run manually via multi-gitter:
#   multi-gitter --config ./cicd/multi-gitter-config \
#                --branch security-policy \
#                --pr-title "Add SECURITY.md" \
#                run ./bulk-utils/rollout_security_md.sh

set -euo pipefail

# SECURITY_TEMPLATE may be injected by the workflow as an absolute path.
# Fall back to dirname-based resolution for local/manual runs.
SECURITY_TEMPLATE="${SECURITY_TEMPLATE:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../data/SECURITY.md"}"

# GitHub recognises SECURITY.md in the repo root, docs/ or .github/ (any case).
# Never overwrite an existing policy a maintainer wrote.
existing=""
for dir in . docs .github; do
  if [ -d "$dir" ]; then
    existing=$(find "$dir" -maxdepth 1 -type f -iname 'SECURITY.md' | head -n 1)
    [ -n "$existing" ] && break
  fi
done
if [ -n "$existing" ]; then
  echo "SKIP: ${REPOSITORY:-<unknown>} already has $existing"
  exit 0
fi

if [ -z "${REPOSITORY:-}" ]; then
  echo "ERROR: REPOSITORY is not set; cannot fill in the advisory link" >&2
  exit 1
fi

sed "s|{{REPOSITORY}}|${REPOSITORY}|g" "$SECURITY_TEMPLATE" > SECURITY.md
echo "OK: wrote SECURITY.md in ${REPOSITORY}"
